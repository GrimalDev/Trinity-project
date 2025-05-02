package middlewares

import (
	"fmt"
	"net/http"
	"strings"

	"trinity/backend/items/entities"

	echo "github.com/labstack/echo/v4"
)

func Permission() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {

			authUser := c.Get("user").(entities.UserBasicStruct)

			Roles := authUser.Roles

			// Extract resource from path
			// e.g., "/api/users/123" -> "users"
			action := c.Request().Method

			hasPermission := false
			for _, role := range Roles {
				permissions := role.Permissions
				for _, permission := range permissions {
					permParts := strings.Split(permission.Resource, "/*")
					isWildcard := len(permParts) > 1

					// Check if resource matches exactly or matches wildcard prefix
					resourceMatches := permission.Resource == c.Path() ||
						(isWildcard && strings.HasPrefix(c.Path(), permParts[0]))

					if resourceMatches {
						for _, allowedMethod := range permission.Actions {
							allowedAction := strings.Split(allowedMethod, ":")
							pathHasSelf := len(strings.Split(c.Path(), "self")) > 1

							if allowedAction[0] != action {
								continue
							} else if len(allowedAction) == 1 {
								hasPermission = true
								break
							}

							if pathHasSelf || len(allowedAction) > 1 && allowedAction[1] == "OTHER" {
								hasPermission = true
								break
							}
						}
					}
				}
			}

			if !hasPermission {
				return c.JSON(http.StatusForbidden, map[string]string{
					"error": fmt.Sprintf("no permission for %s on resource %s", action, c.Path()),
				})
			}

			return next(c)
		}
	}
}
