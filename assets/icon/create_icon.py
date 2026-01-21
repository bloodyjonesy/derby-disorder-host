#!/usr/bin/env python3
import struct
import zlib

def create_png(width, height, pixels):
    """Create a PNG file from pixel data"""
    def write_chunk(chunk_type, data):
        chunk = chunk_type + data
        crc = zlib.crc32(chunk) & 0xffffffff
        return struct.pack('>I', len(data)) + chunk + struct.pack('>I', crc)
    
    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = write_chunk(b'IHDR', ihdr_data)
    
    # IDAT chunk (compressed image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # Filter byte
        for x in range(width):
            idx = (y * width + x) * 4
            raw_data += bytes(pixels[idx:idx+4])
    
    compressed = zlib.compress(raw_data, 9)
    idat = write_chunk(b'IDAT', compressed)
    
    # IEND chunk
    iend = write_chunk(b'IEND', b'')
    
    return signature + ihdr + idat + iend

def create_app_icon():
    """Create a fun Derby Disorder icon"""
    size = 512
    pixels = [0] * (size * size * 4)
    
    center = size // 2
    
    for y in range(size):
        for x in range(size):
            idx = (y * size + x) * 4
            
            # Distance from center
            dx = x - center
            dy = y - center
            dist = (dx*dx + dy*dy) ** 0.5
            
            # Background - dark blue gradient
            if dist < 240:
                # Inside circle
                bg_r = int(10 + (y / size) * 20)
                bg_g = int(10 + (y / size) * 30)
                bg_b = int(46 + (y / size) * 20)
                
                # Trophy shape (golden)
                trophy_left = center - 80
                trophy_right = center + 80
                trophy_top = 100
                trophy_bottom = 280
                
                is_trophy = False
                if trophy_left < x < trophy_right and trophy_top < y < trophy_bottom:
                    # Main cup body
                    cup_width = 80 - abs(y - 150) * 0.4
                    if abs(x - center) < cup_width:
                        is_trophy = True
                
                # Trophy base
                if center - 50 < x < center + 50 and 280 < y < 320:
                    is_trophy = True
                if center - 70 < x < center + 70 and 310 < y < 340:
                    is_trophy = True
                
                if is_trophy:
                    # Golden gradient
                    pixels[idx] = 255  # R
                    pixels[idx+1] = 215 - int((y - trophy_top) * 0.3)  # G  
                    pixels[idx+2] = 0  # B
                    pixels[idx+3] = 255  # A
                else:
                    # Cyan/pink racing stripes
                    stripe = ((x + y) // 30) % 3
                    if 380 < y < 420:
                        if stripe == 0:
                            pixels[idx] = 0
                            pixels[idx+1] = 255
                            pixels[idx+2] = 255
                            pixels[idx+3] = 200
                        elif stripe == 1:
                            pixels[idx] = 255
                            pixels[idx+1] = 0
                            pixels[idx+2] = 255
                            pixels[idx+3] = 200
                        else:
                            pixels[idx] = bg_r
                            pixels[idx+1] = bg_g
                            pixels[idx+2] = bg_b
                            pixels[idx+3] = 255
                    else:
                        pixels[idx] = bg_r
                        pixels[idx+1] = bg_g
                        pixels[idx+2] = bg_b
                        pixels[idx+3] = 255
                
                # Border glow
                if 235 < dist < 245:
                    glow = 1 - abs(dist - 240) / 5
                    pixels[idx] = int(pixels[idx] * (1-glow) + 0 * glow)
                    pixels[idx+1] = int(pixels[idx+1] * (1-glow) + 255 * glow)
                    pixels[idx+2] = int(pixels[idx+2] * (1-glow) + 255 * glow)
                    
            else:
                # Outside - transparent
                pixels[idx] = 0
                pixels[idx+1] = 0
                pixels[idx+2] = 0
                pixels[idx+3] = 0
    
    return create_png(size, size, pixels)

# Generate icon
icon_data = create_app_icon()
with open('app_icon.png', 'wb') as f:
    f.write(icon_data)

print(f"Created app_icon.png ({len(icon_data)} bytes)")

# Also create foreground icon (same as main for now)
with open('app_icon_foreground.png', 'wb') as f:
    f.write(icon_data)
print("Created app_icon_foreground.png")
