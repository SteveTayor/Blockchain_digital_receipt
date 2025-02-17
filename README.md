# BlockReceipt

BlockReceipt is a Flutter-based mobile application for securely managing digital receipts using blockchain technology. It allows users to add new receipts, capture vendor/amount/date/category information, attach an image, and record a transaction hash on the Ethereum test network (Goerli) for immutability.

## Features

1. **Home/Dashboard Screen**
   - Shows recent receipts, receipt statistics, and categories.
   - Provides an overview of total receipts and total spent.
   - Allows navigation to add a new receipt.

2. **Add New Receipt Screen**
   - Input fields for vendor name, amount, transaction date, category, payment method, store location, and notes.
   - Option to attach a receipt image from the gallery.
   - Submits receipt data to a blockchain service (using `web3dart`) for a transaction hash.

3. **Receipt Details Screen**
   - Displays all receipt details: vendor, amount, date/time, payment method, store location, and notes.
   - Shows a list of items associated with the receipt.
   - Shows the blockchain transaction hash if recorded successfully.
   - Option to share or take additional actions (placeholder).

4. **Blockchain Integration**
   - Demonstrates how to log a string of receipt data on Ethereum’s Goerli testnet.
   - Uses a private key to sign zero-value transactions containing the receipt data.

## Getting Started

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/your-username/blockreceipt.git
   cd blockreceipt
