package entities

type LogStruct struct {
	Id         string `bson:"_id,omitempty"`
	TableName  string `bson:"tableName"`
	ActionType string `bson:"actionType"`
	ModifiedAt string `bson:"modifiedAt"`
}
