export interface Product {
  product_name: string;
  brands: string;
  categories: string;
  image_url: string;
  image_thumb_url: string;
  image_nutrition_url: string;
  code: string;
}
export type ProductBasic = {
  reference: string;
  price_vat: number;
  price_not: number;
  stock_quantity: number;
};

export type Images = {
  S: string;
  XL: string;
};

export type StockItem = {
  id: string;
  name: string;
  reference: string;
  price_vat: number;
  price_not: number;
  brand: string;
  images: Images;
  category: string;
  nutritionalInfo: string;
  quantity: number;
};

export type StatsProduct = {
  name: string;
  total: number;
};
