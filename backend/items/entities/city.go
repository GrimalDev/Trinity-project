package entities

type CityStruct struct {
	Id         string `bson:"_id,omitempty" json:"id"`
	Name       string `bson:"name" json:"name"`
	PostalCode string `bson:"postalCode" json:"postalCode"`
	Country    string `bson:"country" json:"country"`
}
