package entities

type UserStruct struct {
	Id          string          `bson:"_id,omitempty"`
	FirstName   string          `bson:"firstName" json:"firstName" form:"firstName" validate:"required"`
	LastName    string          `bson:"lastName" json:"lastName" form:"lastName" validate:"required"`
	Email       string          `bson:"email" json:"email" form:"email" validate:"required,email"`
	Password    string          `bson:"password" json:"password" form:"password" validate:"required,min=8"`
	PhoneNumber string          `bson:"phoneNumber" json:"phoneNumber" form:"phoneNumber"`
	City        CityStruct      `bson:"city" json:"city" form:"city"`
	Address     string          `bson:"address" json:"address" form:"address"`
	Logs        []LogStruct     `bson:"logs,omitempty"`
	Invoices    []InvoiceStruct `bson:"invoices,omitempty"`
	Roles       []RoleStruct    `bson:"roles,omitempty"`
	Reports     []ReportStruct  `bson:"reports,omitempty"`
	DeviceToken string          `bson:"deviceToken,omitempty" json:"deviceToken,omitempty"`
	Archived    bool            `bson:"archived,omitempty"`
}

type UserStructProtected struct {
	Id          string          `bson:"_id,omitempty" json:"id"`
	FirstName   string          `bson:"firstName" json:"firstName" form:"firstName" validate:"required"`
	LastName    string          `bson:"lastName" json:"lastName" form:"lastName" validate:"required"`
	Email       string          `bson:"email" json:"email" form:"email" validate:"required,email"`
	PhoneNumber string          `bson:"phoneNumber" json:"phoneNumber" form:"phoneNumber"`
	City        CityStruct      `bson:"city" json:"city" form:"city"`
	Address     string          `bson:"address" json:"address" form:"address"`
	Invoices    []InvoiceStruct `bson:"invoices,omitempty"`
	Roles       []RoleStruct    `bson:"roles,omitempty"`
}

type UserBasicStruct struct {
	Id        string       `bson:"_id,omitempty" json:"id"`
	FirstName string       `bson:"firstName" json:"firstName"`
	LastName  string       `bson:"lastName" json:"lastName"`
	Email     string       `bson:"email" json:"email"`
	Roles     []RoleStruct `bson:"roles" json:"roles"`
	Archived  bool         `bson:"archived" json:"archived"`
}

type ModificationUserStruct struct {
	Id          string           `bson:"_id,omitempty" json:"id" validate:"required"`
	FirstName   string           `bson:"firstName,omitempty" json:"firstName" form:"firstName"`
	LastName    string           `bson:"lastName,omitempty" json:"lastName" form:"lastName"`
	Email       string           `bson:"email,omitempty" json:"email" form:"email"`
	PhoneNumber string           `bson:"phoneNumber,omitempty" json:"phoneNumber" form:"phoneNumber"`
	City        CityStruct       `bson:"city,omitempty" json:"city" form:"city"`
	Address     string           `bson:"address,omitempty" json:"address" form:"address"`
	Roles       []UserRoleStruct `bson:"roles,omitempty"`
	Archived    bool             `bson:"archived,omitempty"`
}
