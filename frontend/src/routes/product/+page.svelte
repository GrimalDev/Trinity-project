<script lang="ts">
  import * as Card from "$lib/components/ui/card/index.js";
  import { Input } from "$lib/components/ui/input";
  import { Button } from "$lib/components/ui/button";
  import { createProduct } from "$lib/api/apiProducts";
  import type { Product } from "$lib/types/product";
  import { toast } from "svelte-sonner";
  import { Toaster } from "svelte-sonner";

  // Reactive variables declaration using $state
  let searchQuery = $state("");
  //let allSuggestions = $state<Product[]>([]);
  let displayedSuggestions = $state<Product[]>([]);
  let selectedProduct = $state<Product | null>(null);
  let priceVat = $state("");
  let priceNot = $state("");
  let stockQuantity = $state("");
  let taxRate = $state("20");

  let searchTimeout: ReturnType<typeof setTimeout> | null = null;
  let selectedIndex = $state(-1);
  let isSearchResultsVisible = $state(false);

  // Handle keyboard navigation
  function handleKeydown(event: KeyboardEvent) {
    if (!displayedSuggestions.length) return;

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        selectedIndex = Math.min(
          selectedIndex + 1,
          displayedSuggestions.length - 1,
        );
        scrollSelectedIntoView();
        break;
      case "ArrowUp":
        event.preventDefault();
        selectedIndex = Math.max(selectedIndex - 1, -1);
        scrollSelectedIntoView();
        break;
      case "Enter":
        event.preventDefault();
        if (selectedIndex >= 0) {
          selectProduct(displayedSuggestions[selectedIndex]);
          isSearchResultsVisible = false;
          selectedIndex = -1;
        }
        break;
      case "Escape":
        isSearchResultsVisible = false;
        selectedIndex = -1;
        break;
    }
  }

  function scrollSelectedIntoView() {
    setTimeout(() => {
      const selectedElement = document.querySelector('[data-selected="true"]');
      if (selectedElement) {
        selectedElement.scrollIntoView({ block: "nearest" });
      }
    }, 0);
  }

  // Fonction pour gérer le délai de recherche
  function handleSearchInput() {
    if (searchTimeout) clearTimeout(searchTimeout);

    searchTimeout = setTimeout(() => {
      searchProduct();
    }, 600);
  }

  // Function to search for a product
  async function searchProduct() {
    if (searchQuery.length < 3) {
      displayedSuggestions = [];
      isSearchResultsVisible = false;
      return;
    }

    let url = "";

    if (/^\d+$/.test(searchQuery)) {
      url = `https://world.openfoodfacts.org/api/v0/product/${searchQuery}.json`;
    } else {
      url = `https://world.openfoodfacts.org/cgi/search.pl?search_terms=${searchQuery}&page_size=10&page=1&json=1`;
    }

    const response = await fetch(url);
    const data = await response.json();

    if (data.products) {
      displayedSuggestions = data.products;
      isSearchResultsVisible = true;
      selectedIndex = -1;
    } else if (data.product) {
      displayedSuggestions = [data.product];
      isSearchResultsVisible = true;
      selectedIndex = -1;
    } else {
      displayedSuggestions = [];
      isSearchResultsVisible = false;
      selectedIndex = -1;
    }
  }

  // Fonction pour sélectionner un produit
  function selectProduct(product: Product) {
    selectedProduct = product;
    priceVat = "";
    priceNot = "";
    stockQuantity = "";
  }

  // Fonction pour soumettre un produit
  async function submitProduct() {
    if (!selectedProduct || !taxRate || !stockQuantity) return;

    const requestBody = {
      reference: selectedProduct.code,
      price_vat: parseFloat(priceVat),
      price_not: parseFloat(priceNot),
      stock_quantity: parseInt(stockQuantity),
    };

    requestBody.price_vat =
      requestBody.price_not * (1 + parseFloat(taxRate) / 100);

    try {
      const response = await createProduct({
        reference: selectedProduct.code,
        price_vat: requestBody.price_vat,
        price_not: requestBody.price_not,
        stock_quantity: requestBody.stock_quantity,
      });

      if (response) {
        toast.success("Product added successfully!", {
          description: `${selectedProduct.product_name} has been added to your inventory`,
          duration: 3000,
          action: {
            label: "View",
            onClick: () => console.log("View product"),
          },
        });
        // Reset form
        selectedProduct = null;
        searchQuery = "";
        displayedSuggestions = [];
      } else {
        toast.error("Failed to add product", {
          description:
            "Please try again or contact support if the problem persists.",
          duration: 4000,
        });
      }
    } catch (error) {
      toast.error("Error occurred", {
        description: "An unexpected error occurred while adding the product.",
        duration: 4000,
      });
    }
  }

  // Fonction pour surligner le texte recherché
  function highlightText(text: string): string {
    const query = searchQuery.toLowerCase();
    if (!query) return text;

    const regex = new RegExp(`(${query})`, "gi");
    return text.replace(
      regex,
      '<span class="text-blue-500 font-semibold">$1</span>',
    );
  }
</script>

<main class="p-6">
  <div class="max-w-6xl w-full mx-auto grid grid-cols-2 gap-6">
    <!-- Colonne de gauche pour la recherche -->
    <div class="flex flex-col space-y-4">
      <Input
        type="text"
        bind:value={searchQuery}
        on:input={handleSearchInput}
        on:keydown={handleKeydown}
        placeholder="Search for a product or reference. Use ↑↓ to navigate, Enter to select"
      />

      {#if displayedSuggestions.length > 0}
        <ul
          class="bg-card text-card-foreground border shadow-sm rounded-lg p-2 w-full mt-4 max-h-[300px] overflow-y-auto [&::-webkit-scrollbar]:hidden [-ms-overflow-style:'none'] [scrollbar-width:none]"
        >
          {#each displayedSuggestions as product}
            <button
              class="cursor-pointer w-full text-left p-2 rounded transition-colors {selectedIndex ===
              displayedSuggestions.indexOf(product)
                ? 'bg-muted'
                : 'hover:bg-muted'}"
              onclick={() => selectProduct(product)}
              data-selected={selectedIndex ===
                displayedSuggestions.indexOf(product)}
            >
              {@html highlightText(product.product_name || "Unknown name")} ({product.code})
            </button>
          {/each}
        </ul>
      {/if}
    </div>

    <!-- Colonne de droite pour le formulaire -->
    <div class="flex flex-col space-y-4">
      <h2 class="text-2xl font-bold mb-4">Add a product</h2>

      {#if selectedProduct}
        <Card.Root class="p-4">
          <Card.Header>
            <Card.Title>Selected Product</Card.Title>
            <Card.Description>
              <p>
                <strong>Name:</strong>
                {@html highlightText(
                  selectedProduct?.product_name || "Unknown name",
                )}
              </p>
              <p>
                <strong>Brand:</strong>
                {@html highlightText(
                  selectedProduct?.brands || "Unknown brand",
                )}
              </p>
              <p>
                <strong>Category:</strong>
                {@html highlightText(
                  selectedProduct?.categories || "Unknown category",
                )}
              </p>
            </Card.Description>
          </Card.Header>
          <Card.Content class="flex flex-col items-center">
            <img
              src={selectedProduct?.image_url || "/placeholder.jpg"}
              alt="Image of {selectedProduct?.product_name}"
              class="w-32 mt-2 rounded"
            />
          </Card.Content>
          <Card.Footer class="flex flex-col space-y-2">
            <Input
              type="number"
              bind:value={priceNot}
              placeholder="Price excl. VAT (€)"
            />
            <select
              class="flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              bind:value={taxRate}
            >
              <option value="5.5">VAT 5.5%</option>
              <option value="10">VAT 10%</option>
              <option value="20">VAT 20%</option>
            </select>
            <Input
              type="number"
              bind:value={stockQuantity}
              placeholder="Available stock"
            />
            <div class="flex justify-end">
              <Button onclick={submitProduct} class="mt-4">Save</Button>
            </div>
          </Card.Footer>
        </Card.Root>
      {/if}
    </div>
  </div>
</main>
<Toaster richColors closeButton />
