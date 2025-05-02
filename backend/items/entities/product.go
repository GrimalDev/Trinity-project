package entities

type ProductStruct struct {
	Id                     string       `bson:"_id,omitempty" json:"id" validate:"required"`
	Reference              string       `bson:"reference" json:"reference" validate:"required"`
	Images                 ImagesStruct `bson:"images,omitempty" json:"images"`
	PriceVat               float64      `bson:"priceVat" json:"price_vat" validate:"required"`
	PriceNot               float64      `bson:"priceNot" json:"price_not"`
	StockQuantity          float64      `bson:"stockQuantity" json:"stock_quantity"`
	Name                   string       `bson:"name" json:"name" validate:"required"`
	Brand                  string       `bson:"brand" json:"brand"`
	Category               string       `bson:"category" json:"category"`
	NutritionalInformation string       `bson:"nutritionalInformation" json:"nutritional_information"`
	Archived               bool         `bson:"archived" json:"archived"`
}

type ProductOrder struct {
	Id                     string       `bson:"_id,omitempty" json:"id" validate:"required"`
	Reference              string       `bson:"reference" json:"reference" validate:"required"`
	Images                 ImagesStruct `bson:"images,omitempty" json:"images"`
	PriceVat               float64      `bson:"priceVat" json:"price_vat" validate:"required"`
	PriceNot               float64      `bson:"priceNot" json:"price_not"`
	Name                   string       `bson:"name" json:"name" validate:"required"`
	Brand                  string       `bson:"brand" json:"brand"`
	Category               string       `bson:"category" json:"category"`
	NutritionalInformation string       `bson:"nutritionalInformation" json:"nutritional_information"`
}

type ProductBasic struct {
	Reference     string  `json:"reference" validate:"required"`
	PriceVat      float64 `json:"price_vat" validate:"required"`
	PriceNot      float64 `json:"price_not" validate:"required"`
	StockQuantity float64 `json:"stock_quantity" validate:"required"`
}

type StatsProduct struct {
	Name  string `json:"name"`
	Total int32  `json:"total"`
}
