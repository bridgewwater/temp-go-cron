package biz

type Biz struct {
	Info   string `json:"info,omitempty" example:"input info here"`
	Id     string `json:"id,omitempty"  example:"id123zqqeeadg24qasd"`
	Offset int    `json:"offset,omitempty"  example:"0"`
	Limit  int    `json:"limit,omitempty"  example:"10"`
}
