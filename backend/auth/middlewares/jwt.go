package middlewares

import (
	"net/http"
	"os"
	"strings"
	"time"
	"trinity/backend/items/models"

	jwt "github.com/golang-jwt/jwt/v5"
	echojwt "github.com/labstack/echo-jwt/v4"
	echo "github.com/labstack/echo/v4"
)

// Declare jwtSecret at the package level
var jwtSecret string

// Initialize jwtSecret from the environment variable
func init() {
	jwtSecret = strings.TrimSpace(os.Getenv("JWT_SECRET"))
	if jwtSecret == "" {
		// Handle the case where the environment variable is not set
		panic("JWT_SECRET environment variable is not set")
	}
}

var ConfigJwt = echojwt.Config{
	SigningKey: []byte(os.Getenv("JWT_SECRET")),
	ContextKey: "token",
	NewClaimsFunc: func(c echo.Context) jwt.Claims {
		return new(jwt.RegisteredClaims)
	},
	// NewClaimsFunc: jwt.RegisteredClaims,
	SuccessHandler: func(c echo.Context) {
		token := c.Get("token").(*jwt.Token)
		claims := token.Claims.(*jwt.RegisteredClaims)
		// log.Println("claims", claims)

		userID, err := claims.GetSubject()
		if err != nil {
			panic(echo.NewHTTPError(http.StatusBadRequest, "User ID not found in token"))
		}

		// Fetch the user from the database
		user, err := models.GetUserForJWT(userID)
		if err != nil {
			panic(echo.NewHTTPError(http.StatusBadRequest, "Failed to retrieve user"))
		}

		// Set the user in the context
		c.Set("user", user)
	},
}

func JWTLogin(username string, password string) (string, error) {
	user, err := models.Login(username, password)

	// log.Println(username, password)
	if err != nil {
		// log.Println(username, password)
		return "", err
	}

	// Set custom claims
	claims := jwt.RegisteredClaims{
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 72)),
		Subject:   user.Id,
	}

	// Create token with claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Generate encoded token and send it as response.
	signed_token, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return "", err
	}

	return signed_token, nil
}
