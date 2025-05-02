package entities

type PromotStruct struct {
	Id            string         `json:"id" bson:"_id,omitempty"`
	Name          string         `json:"name" bson:"name"`
	Description   string         `json:"description" bson:"description"`
	DiscountType  string         `json:"discount_type" bson:"discount_type"` // percentage, fixed, bogo
	DiscountValue float64        `json:"discount_value" bson:"discount_value"`
	Code          string         `json:"code" bson:"code"`
	StartDate     string         `json:"start_date" bson:"start_date"`
	EndDate       string         `json:"end_date" bson:"end_date"`
	Products      []ProductOrder `json:"products" bson:"products"`
	MinPurchase   float64        `json:"min_purchase" bson:"min_purchase"`
	Status        string         `json:"status" bson:"status"` // active, inactive, expired
	CreatedAt     string         `json:"created_at" bson:"created_at"`
	UpdatedAt     string         `json:"updated_at" bson:"updated_at"`
}

type PromoResponse struct {
	Id            string         `json:"id" bson:"_id,omitempty"`
	Name          string         `json:"name" bson:"name"`
	Description   string         `json:"description" bson:"description"`
	DiscountType  string         `json:"discount_type" bson:"discount_type"` // percentage, fixed, bogo
	DiscountValue float64        `json:"discount_value" bson:"discount_value"`
	Code          string         `json:"code" bson:"code"`
	StartDate     string         `json:"start_date" bson:"start_date"`
	EndDate       string         `json:"end_date" bson:"end_date"`
	Products      []ProductOrder `json:"products" bson:"products"`
	MinPurchase   float64        `json:"min_purchase" bson:"min_purchase"`
}
