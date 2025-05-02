package entities

type RoleStruct struct {
	Id          string             `bson:"_id,omitempty" json:"id"`
	Name        string             `bson:"name" json:"name"`
	Permissions []PermissionStruct `bson:"permissions,omitempty" json:"permissions"`
}

type UserRoleStruct struct {
	RoleId string `bson:"_id,omitempty" json:"roleid"`
	Name   string `bson:"name" json:"name"`
}
