import type { ProductBasic, StockItem } from "$lib/types/product";
import { apiClientProtected } from "./api";

export async function getProducts(): Promise<StockItem[]> {
  try {
    const response = await apiClientProtected.get(`/product`);
    return response.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
}

export async function createProduct(product: ProductBasic): Promise<StockItem> {
  try {
    const response = await apiClientProtected.post(`/product`, product);
    return response.data;
  } catch (error) {
    console.error("Error creating product:", error);
    throw error;
  }
}

export async function updateProduct(
  id: string,
  product: Partial<StockItem>,
): Promise<StockItem> {
  try {
    const response = await apiClientProtected.put(`/product/${id}`, product);
    return response.data;
  } catch (error) {
    console.error("Error updating product:", error);
    throw error;
  }
}

export async function deleteProduct(id: string): Promise<void> {
  try {
    await apiClientProtected.delete(`/product/${id}`);
  } catch (error) {
    console.error("Error deleting product:", error);
    throw error;
  }
}
