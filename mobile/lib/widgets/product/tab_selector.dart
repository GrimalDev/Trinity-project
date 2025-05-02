import 'package:flutter/material.dart';

/// A custom tab selector widget for the product page
class TabSelector extends StatelessWidget {
  final String selectedTab;
  final VoidCallback onProduitTabPressed;
  final VoidCallback onDetailTabPressed;

  const TabSelector({
    super.key,
    required this.selectedTab,
    required this.onProduitTabPressed,
    required this.onDetailTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: selectedTab == 'produit'
                ? 0
                : MediaQuery.of(context).size.width * 0.5 - 32,
            right: selectedTab == 'produit'
                ? MediaQuery.of(context).size.width * 0.5 - 32
                : 0,
            top: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Tab buttons
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: 'Produit',
                  isSelected: selectedTab == 'produit',
                  onTap: onProduitTabPressed,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: 'Details',
                  isSelected: selectedTab == 'details',
                  onTap: onDetailTabPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
