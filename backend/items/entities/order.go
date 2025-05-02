package entities

import (
	"time"
)

type OrderStruct struct {
	Id            string               `bson:"_id,omitempty" json:"id"`
	Date          time.Time            `bson:"date" json:"date"`
	Status        string               `bson:"status" json:"status"` // e.g., "pending", "paid", "cancelled"
	Products      []OrderProductStruct `bson:"products" json:"products"`
	PaymentMethod string               `bson:"paymentMethod" json:"paymentMethod"` // e.g., "PAYPAL"
	PaymentInfo   PaymentInfo          `bson:"paymentInfo" json:"paymentInfo"`     // PayPal payment details
}

type OrderProductStruct struct {
	ProductId string  `bson:"productId" json:"productId"`
	Quantity  int     `bson:"quantity" json:"quantity"`
	Price     float64 `bson:"price" json:"price"`
}

type OrderWithProductDetails struct {
	Id          string                    `bson:"_id,omitempty" json:"id"`
	Date        time.Time                 `bson:"date" json:"date"`
	Status      string                    `bson:"status" json:"status"`
	Products    []OrderProductWithDetails `bson:"products" json:"products"`
	PaymentInfo PaymentInfo               `bson:"paymentInfo" json:"paymentInfo"`
}

type OrderProductWithDetails struct {
	Product  ProductOrder `bson:"product" json:"product"` // Full product details
	Quantity int          `bson:"quantity" json:"quantity"`
	Price    float64      `bson:"price" json:"price"` // Total price for this product (PriceNot * Quantity)
}

// PaymentLink represents a link returned by PayPal (e.g., approval URL)
type PaymentLink struct {
	Href   string `bson:"href" json:"href"`
	Rel    string `bson:"rel" json:"rel"`
	Method string `bson:"method" json:"method"`
}

type PaymentInfo struct {
	ServiceOrderID string `bson:"serviceOrderId,omitempty"`
	PaypalOrderID  string `bson:"paypalOrderId,omitempty"` // Add this
	Status         string `bson:"status,omitempty"`
}

func (o *OrderStruct) GetTotalPrice() float64 {
	var total float64
	for _, product := range o.Products {
		total += product.Price
	}
	return total
}

func (o *OrderWithProductDetails) GetTotalPrice() float64 {
	var total float64
	for _, product := range o.Products {
		total += product.Price
	}
	return total
}
