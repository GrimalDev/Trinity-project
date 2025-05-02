package entities

type SupplierStruct struct {
	Id          string          `bson:"_id,omitempty"`
	Name        string          `bson:"name"`
	Email       string          `bson:"email"`
	PhoneNumber string          `bson:"phoneNumber"`
	City        CityStruct      `bson:"city"`
	Address     string          `bson:"address"`
	LegalStatus string          `bson:"legalStatus"`
	Invoices    []InvoiceStruct `bson:"invoices"`
}
