import type { StatsProduct } from "$lib/types/product";
import { apiClientProtected } from "./api";

export async function getEarnings(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/earnings`);
    return response.data.earnings;
  } catch (error) {
    console.error("Error fetching earnings:", error);
    throw error;
  }
}

export async function getTotalUser(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/user_total`);
    return response.data.total_user;
  } catch (error) {
    console.error("Error fetching user total:", error);
    throw error;
  }
}

export async function getTotalCommande(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/commande_total`);
    return response.data.total_commande;
  } catch (error) {
    console.error("Error fetching commandes:", error);
    throw error;
  }
}

export async function getAverageSpending(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/average_spending`);
    return response.data.average_spending;
  } catch (error) {
    console.error("Error fetching commandes:", error);
    throw error;
  }
}

export async function getTotalProductSold(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/total_product_sold`);
    return response.data.total_product_sold;
  } catch (error) {
    console.error("Error fetching commandes:", error);
    throw error;
  }
}

export async function getTotalCategories(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/total_categories`);
    return response.data.total_categories;
  } catch (error) {
    console.error("Error fetching commandes:", error);
    throw error;
  }
}

export async function getTotalProductStock(): Promise<number> {
  try {
    const response = await apiClientProtected.get(`/stats/total_product_stock`);
    return response.data.total_product_stock;
  } catch (error) {
    console.error("Error fetching product stock:", error);
    throw error;
  }
}

export async function getAverageProductCost(): Promise<number> {
  try {
    const response = await apiClientProtected.get(
      `/stats/average_product_cost`,
    );
    return response.data.average_product_cost;
  } catch (error) {
    console.error("Error fetching product cost:", error);
    throw error;
  }
}

export async function getProductPerCategory(): Promise<StatsProduct[]> {
  try {
    const response = await apiClientProtected.get(
      `/stats/products_per_category`,
    );
    return response.data.products_per_category;
  } catch (error) {
    console.error("Error fetching product cost:", error);
    throw error;
  }
}
