import { NextRequest, NextResponse } from "next/server";
import fetch from "node-fetch";

const PHOTO_DIR_URL = process.env.PHOTO_DIR_URL;

export async function GET(req: NextRequest) {
  try {
    const response = await fetch(`${PHOTO_DIR_URL}/images`);
    if (!response.ok) {
      throw new Error("Failed to fetch images");
    }
    const images = await response.json();
    return NextResponse.json(images);
  } catch (err) {
    console.error("Error fetching images:", err);
    return NextResponse.json(
      { error: "Unable to fetch images" },
      { status: 500 }
    );
  }
}
