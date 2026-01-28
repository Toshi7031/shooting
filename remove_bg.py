import cv2
import numpy as np
import sys
import os

def process_image(image_path):
    img = cv2.imread(image_path)
    if img is None:
        print(f"Error: Could not load image {image_path}")
        return

    # Convert to RGBA
    img = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)

    # Define green range
    # Standard Green is (0, 255, 0) in BGR check
    # Let's target #00FF00 with some tolerance
    lower_green = np.array([0, 200, 0])
    upper_green = np.array([100, 255, 100])

    # Create mask in BGR (before conversion handled? No, usually HSV is better but simple BGR check works for perfect green)
    # Actually let's use BGR for mask
    bgr = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
    mask = cv2.inRange(bgr, lower_green, upper_green)

    # Set alpha to 0 where mask is true
    img[mask > 0] = [0, 0, 0, 0]

    # Save
    output_path = image_path # Overwrite? Or new? Let's overwrite for simplicity in this workflow
    cv2.imwrite(output_path, img)
    print(f"Processed: {image_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python remove_bg.py <image_path>")
        sys.exit(1)
    
    process_image(sys.argv[1])
