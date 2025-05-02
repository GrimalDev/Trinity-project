package controllers

import (
	"net/http"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

type TokenRequest struct {
	Token string `json:"token" validate:"required"`
}

type NotificationRequest struct {
	Title string `json:"title" validate:"required"`
	Body  string `json:"body" validate:"required"`
}

func NotifyHandler(c echo.Context) error {
	var req NotificationRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
	}

	if err := c.Validate(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "request malformed"})
	}

	err := models.SendNotification(req.Title, req.Body)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, err)
	}

	return c.JSON(http.StatusOK, "Notification sent")
}

func RegisterToken(c echo.Context) error {
	user, ok := c.Get("user").(entities.UserBasicStruct)
	if !ok {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "user not authenticated"})
	}
	userId := user.Id

	var req TokenRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
	}

	if err := c.Validate(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "request malformed"})
	}

	err := models.UpdateDeviceToken(userId, req.Token)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to register token"})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"token":   req.Token,
		"message": "token registered successfully",
	})
}
