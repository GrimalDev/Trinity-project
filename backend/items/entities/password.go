package entities

type LoginStruct struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type PasswordUpdateStruct struct {
	CurrentPassword string `json:"current_password" validate:"required"`
	NewPassword     string `json:"new_password" validate:"required,min=8"`
}

type AdminPasswordUpdateStruct struct {
	NewPassword string `json:"new_password" validate:"required,min=8"`
}
