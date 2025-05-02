package controllers

import (
	"fmt"
	"net/http"
	"trinity/backend/auth/middlewares"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

/////////////////////////////////////////////////  user controller  //////////////////////////////////////////////////

func GetUsers(c echo.Context) error {
	users, err := models.GetUsers(0, 10)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting users"})
	}

	return c.JSON(http.StatusOK, users)
}

func GetTotalUser(c echo.Context) error {
	users, err := models.GetUsers(0, 100)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting users"})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{"total_user": len(users)})
}

func GetSelfUserBasic(c echo.Context) error {
	authenticated_user := c.Get("user").(entities.UserBasicStruct)

	return c.JSON(http.StatusOK, authenticated_user)
}

func GetUserBasic(c echo.Context) error {
	userBasic, err := models.GetBasicUserFromId(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error retrieving user details"})
	}

	return c.JSON(http.StatusOK, userBasic)
}

func CreateUser(c echo.Context) error {
	var userReq entities.UserStruct
	if err := c.Bind(&userReq); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	fmt.Printf("userReq: %v\n", userReq)

	if err := c.Validate(userReq); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": err.Error(),
		})
	}

	user, err := models.CreateUser(userReq)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, user)
}

func GetSelfDetails(c echo.Context) error {
	authenticated_user := c.Get("user").(entities.UserBasicStruct)

	userDetails, err := models.GetUserDetails(authenticated_user.Id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error retrieving user details"})
	}

	return c.JSON(http.StatusOK, userDetails)
}

func GetUserDetails(c echo.Context) error {
	userDetails, err := models.GetUserDetails(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error retrieving user details"})
	}

	return c.JSON(http.StatusOK, userDetails)
}

func GetOtherUserDetails(c echo.Context) error {
	user_id := c.Param("id")

	user_details, err := models.GetUserDetails(user_id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error retrieving user details"})
	}

	return c.JSON(http.StatusOK, user_details)
}

func UpdateSelfUser(c echo.Context) error {
	authenticated_user := c.Get("user").(entities.UserBasicStruct)

	var userReq entities.ModificationUserStruct

	if err := c.Bind(&userReq); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid form data",
		})
	}

	// Update the user details
	updated_user, err := models.UpdateUser(authenticated_user.Id, userReq)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error updating user details"})
	}

	return c.JSON(http.StatusAccepted, updated_user)
}

func UpdateOtherUser(c echo.Context) error {
	user_id_to_update := c.Param("id")

	var updateUserRequ entities.ModificationUserStruct
	if err := c.Bind(&updateUserRequ); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid form data",
		})
	}

	// Get the user details
	updated_user, err := models.UpdateUser(user_id_to_update, updateUserRequ)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error retrieving user details"})
	}

	return c.JSON(http.StatusAccepted, updated_user)
}

func ArchiveUser(c echo.Context) error {
	err := models.ArchiveUserById(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error archiving user"})
	}

	return c.JSON(http.StatusNoContent, "User removed")
}

func ArchiveSelfUser(c echo.Context) error {
	authenticated_user := c.Get("user").(entities.UserBasicStruct)

	err := models.ArchiveUserById(authenticated_user.Id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error archiving user"})
	}

	return c.JSON(http.StatusNoContent, "User removed")
}

func LoginUser(c echo.Context) error {
	// Get form values
	var user entities.LoginStruct
	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid form data",
		})
	}

	token, err := middlewares.JWTLogin(user.Email, user.Password)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, "Invalid credentials")
	}

	return c.JSON(http.StatusOK, echo.Map{"token": token})
}

func UpdateSelfPassword(c echo.Context) error {
	authenticated_user := c.Get("user").(entities.UserBasicStruct)

	var passwordUpdate entities.PasswordUpdateStruct
	if err := c.Bind(&passwordUpdate); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid form data",
		})
	}

	if err := c.Validate(passwordUpdate); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Validation failed: " + err.Error(),
		})
	}

	// Verify current password
	_, err := models.Login(authenticated_user.Email, passwordUpdate.CurrentPassword)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{
			"error": "Current password is incorrect",
		})
	}

	// Update password
	err = models.UpdatePassword(authenticated_user.Id, passwordUpdate.NewPassword)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to update password",
		})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"message": "Password updated successfully",
	})
}

func AdminUpdateUserPassword(c echo.Context) error {
	userId := c.Param("id")

	var passwordUpdate entities.AdminPasswordUpdateStruct
	if err := c.Bind(&passwordUpdate); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid form data",
		})
	}

	if err := c.Validate(passwordUpdate); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Validation failed: " + err.Error(),
		})
	}

	err := models.UpdatePassword(userId, passwordUpdate.NewPassword)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to update password",
		})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"message": "Password updated successfully",
	})
}
