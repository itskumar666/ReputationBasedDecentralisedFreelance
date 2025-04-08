const axios = require("axios");
const FormData = require("form-data");
require("dotenv").config();
const fs = require("fs");

async function uploadToPinata() {
  const metadata = {
    name: "Ashutosh Kumar",
    description: "Full Stack Developer NFT",
    skills: ["Solidity", "React", "Node"],
    rating: 4.9,
    experience: "3 years",
    image: "ipfs://Qm...your_uploaded_image"
  };

  const res = await axios.post(
    "https://api.pinata.cloud/pinning/pinJSONToIPFS",
    metadata,
    {
      headers: {
        "Content-Type": "application/json",
        pinata_api_key: process.env.PINATA_API_KEY,
        pinata_secret_api_key: process.env.PINATA_SECRET_API_KEY
      }
    }
  );

  console.log("✅ Metadata uploaded:", res.data.IpfsHash);
}

uploadToPinata();
