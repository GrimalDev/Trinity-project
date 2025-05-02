package entities

type ReportStruct struct {
	Id         string `bson:"_id,omitempty"`
	ReportType string `bson:"reportType"`
	Date       string `bson:"date"`
	ReportData string `bson:"reportData"`
}
