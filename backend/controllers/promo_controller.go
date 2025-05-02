package controllers

import (
	"fmt"
	"net/http"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

func GetSelfPromo(c echo.Context) error {
	user := c.Get("user").(entities.UserBasicStruct)

	promotions, err := models.GetUserRecommendedPromotions(user.Id)
	if err != nil {
		fmt.Println(err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting promotions"})
	}

	return c.JSON(http.StatusOK, promotions)
}

func GetDeals(c echo.Context) error {
	promotions, err := models.GetAllDeals()
	if err != nil {
		fmt.Println(err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting promotions"})
	}

	return c.JSON(http.StatusOK, promotions)
}
