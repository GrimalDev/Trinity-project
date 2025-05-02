package entities

type PermissionStruct struct {
	Resource string   `bson:"resource" json:"resource"`
	Actions  []string `bson:"actions" json:"actions"` //"GET", "POST", "PUT", "DELETE"
}
