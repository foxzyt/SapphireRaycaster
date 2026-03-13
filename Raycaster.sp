int config_window_width = 1000;
int config_window_height = 600;

double texId = Sprite.loadTexture("bricks.png");
double sprId = -1;
double texWidth = 64;
double texHeight = 64;

if (texId >= 0) {
    sprId = Sprite.create(texId);
    texWidth = Sprite.getTextureWidth(texId);
    texHeight = Sprite.getTextureHeight(texId);
    IO.printColor("green", "Texture loaded successfully! " + valueToString(texWidth) + "x" + valueToString(texHeight));
} else {
    IO.printColor("red", "Warning: bricks.png not found. Using solid blocks.");
}

double mapW = 64;
double mapH = 64;
class map = Array.create();

double i = 0;
while (i < (mapW * mapH)) {
    Array.append(map, 1);
    i = i + 1;
}

double cx = 32;
double cy = 32;
double steps = 0;
double lastDir = 0;

while (steps < 8000) {
    Array.set(map, Math.floor(cy) * mapW + Math.floor(cx), 0);

    if (Math.rand(0, 100) > 80) {
        lastDir = Math.floor(Math.rand(0, 4));
    }

    if (lastDir == 0) { cx = cx + 1; }
    else if (lastDir == 1) { cx = cx - 1; }
    else if (lastDir == 2) { cy = cy + 1; }
    else { cy = cy - 1; }

    if (cx < 2) { cx = 2; lastDir = 0; }
    if (cx > mapW - 3) { cx = mapW - 3; lastDir = 1; }
    if (cy < 2) { cy = 2; lastDir = 2; }
    if (cy > mapH - 3) { cy = mapH - 3; lastDir = 3; }

    steps = steps + 1;
}

Array.set(map, 32 * mapW + 32, 0);

double playerX = 32.5;
double playerY = 32.5;
double playerDir = 0.0;

double moveSpeed = 0.10;
double rotSpeed = 0.05;

double screenW = config_window_width;
double screenH = config_window_height;
double rayWidth = 4;
double numRays = screenW / rayWidth;

double dirX = 0; double dirY = 0;
double planeX = 0; double planeY = 0;
double rayIndex = 0; double cameraX = 0;
double rayDirX = 0; double rayDirY = 0;
double mapX = 0; double mapY = 0;
double deltaDistX = 0; double deltaDistY = 0;
double stepX = 0; double stepY = 0;
double sideDistX = 0; double sideDistY = 0;
double hit = 0; double side = 0;
double perpWallDist = 0; double lineHeight = 0;
double drawStart = 0; double drawEnd = 0;
double wallX = 0; double texX = 0;

while (true) {
    UI.Begin();
    UI.SetBGColor("#000000");

    if (Input.isKeyPressed("Left")) { playerDir = playerDir - rotSpeed; }
    if (Input.isKeyPressed("Right")) { playerDir = playerDir + rotSpeed; }

    dirX = Math.cos(playerDir);
    dirY = Math.sin(playerDir);
    planeX = -dirY * 0.66;
    planeY = dirX * 0.66;

    double moveX = 0; double moveY = 0;
    if (Input.isKeyPressed("W")) { moveX = moveX + dirX; moveY = moveY + dirY; }
    if (Input.isKeyPressed("S")) { moveX = moveX - dirX; moveY = moveY - dirY; }
    if (Input.isKeyPressed("A")) { moveX = moveX + dirY; moveY = moveY - dirX; }
    if (Input.isKeyPressed("D")) { moveX = moveX - dirY; moveY = moveY + dirX; }

    double moveLen = Math.sqrt(moveX * moveX + moveY * moveY);
    if (moveLen > 0) {
        moveX = (moveX / moveLen) * moveSpeed;
        moveY = (moveY / moveLen) * moveSpeed;

        if (Array.get(map, Math.floor(playerY) * mapW + Math.floor(playerX + moveX * 2)) == 0) {
            playerX = playerX + moveX;
        }
        if (Array.get(map, Math.floor(playerY + moveY * 2) * mapW + Math.floor(playerX)) == 0) {
            playerY = playerY + moveY;
        }
    }

    Draw.rect(0, 0, screenW, screenH / 2, 40, 40, 40);
    Draw.rect(0, screenH / 2, screenW, screenH / 2, 70, 70, 70);

    rayIndex = 0;
    while (rayIndex < numRays) {
        cameraX = 2 * (rayIndex / numRays) - 1;
        rayDirX = dirX + planeX * cameraX;
        rayDirY = dirY + planeY * cameraX;

        mapX = Math.floor(playerX);
        mapY = Math.floor(playerY);

        if (rayDirX == 0) { deltaDistX = 9999999.0; } else { deltaDistX = Math.abs(1.0 / rayDirX); }
        if (rayDirY == 0) { deltaDistY = 9999999.0; } else { deltaDistY = Math.abs(1.0 / rayDirY); }

        if (rayDirX < 0) { stepX = -1; sideDistX = (playerX - mapX) * deltaDistX; }
        else { stepX = 1; sideDistX = (mapX + 1.0 - playerX) * deltaDistX; }

        if (rayDirY < 0) { stepY = -1; sideDistY = (playerY - mapY) * deltaDistY; }
        else { stepY = 1; sideDistY = (mapY + 1.0 - playerY) * deltaDistY; }

        hit = 0; side = 0;
        while (hit == 0) {
            if (sideDistX < sideDistY) {
                sideDistX = sideDistX + deltaDistX;
                mapX = mapX + stepX;
                side = 0;
            } else {
                sideDistY = sideDistY + deltaDistY;
                mapY = mapY + stepY;
                side = 1;
            }

            if (mapX >= 0 and mapX < mapW and mapY >= 0 and mapY < mapH) {
                if (Array.get(map, mapY * mapW + mapX) > 0) { hit = 1; }
            } else {
                hit = 1;
            }
        }

        if (side == 0) { perpWallDist = (mapX - playerX + (1 - stepX) / 2) / rayDirX; }
        else { perpWallDist = (mapY - playerY + (1 - stepY) / 2) / rayDirY; }

        if (perpWallDist <= 0.001) { perpWallDist = 0.001; }
        lineHeight = screenH / perpWallDist;

        if (side == 0) { wallX = playerY + perpWallDist * rayDirY; }
        else { wallX = playerX + perpWallDist * rayDirX; }
        wallX = wallX - Math.floor(wallX);

        texX = Math.floor(wallX * texWidth);

        if (side == 0 and rayDirX > 0) { texX = texWidth - texX - 1; }
        if (side == 1 and rayDirY < 0) { texX = texWidth - texX - 1; }

        drawStart = -lineHeight / 2 + screenH / 2;

        if (sprId >= 0) {
            Sprite.setRect(sprId, texX, 0, 1, texHeight);
            Sprite.setScale(sprId, rayWidth, lineHeight / texHeight);
            Sprite.setPosition(sprId, rayIndex * rayWidth, drawStart);
            Sprite.draw(sprId);
        } else {
            double r = 180; double g = 60; double b = 50;
            if (side == 1) { r = 130; g = 40; b = 30; }

            double dS = drawStart; if (dS < 0) { dS = 0; }
            double dE = drawStart + lineHeight; if (dE > screenH) { dE = screenH; }
            Draw.rect(rayIndex * rayWidth, dS, rayWidth, dE - dS, r, g, b);
        }

        rayIndex = rayIndex + 1;
    }

    double mapOffsetX = 20;
    double mapOffsetY = 20;
    double mmScale = 6;
    double viewDist = 12;

    Draw.rect(mapOffsetX, mapOffsetY, viewDist * 2 * mmScale, viewDist * 2 * mmScale, 30, 30, 30);

    double my = Math.floor(playerY - viewDist);
    double endY = Math.floor(playerY + viewDist);
    while (my < endY) {
        if (my >= 0 and my < mapH) {
            double mx = Math.floor(playerX - viewDist);
            double endX = Math.floor(playerX + viewDist);
            while (mx < endX) {
                if (mx >= 0 and mx < mapW) {
                    if (Array.get(map, my * mapW + mx) > 0) {
                        double drawX = mapOffsetX + (mx - (playerX - viewDist)) * mmScale;
                        double drawY = mapOffsetY + (my - (playerY - viewDist)) * mmScale;
                        Draw.rect(drawX, drawY, mmScale, mmScale, 150, 150, 150);
                    }
                }
                mx = mx + 1;
            }
        }
        my = my + 1;
    }

    double centerRadar = viewDist * mmScale;
    Draw.rect(mapOffsetX + centerRadar - 2, mapOffsetY + centerRadar - 2, 4, 4, 255, 50, 50);
    Draw.line(mapOffsetX + centerRadar, mapOffsetY + centerRadar,
              mapOffsetX + centerRadar + dirX * 12, mapOffsetY + centerRadar + dirY * 12, 50, 255, 50);

    Draw.line(mapOffsetX, mapOffsetY, mapOffsetX + viewDist*2*mmScale, mapOffsetY, 100, 100, 100);
    Draw.line(mapOffsetX, mapOffsetY + viewDist*2*mmScale, mapOffsetX + viewDist*2*mmScale, mapOffsetY + viewDist*2*mmScale, 100, 100, 100);
    Draw.line(mapOffsetX, mapOffsetY, mapOffsetX, mapOffsetY + viewDist*2*mmScale, 100, 100, 100);
    Draw.line(mapOffsetX + viewDist*2*mmScale, mapOffsetY, mapOffsetX + viewDist*2*mmScale, mapOffsetY + viewDist*2*mmScale, 100, 100, 100);

    Draw.text("Built with Sapphire.", 20, 180, 16, 255, 255, 255);

    UI.End();
    System.sleep(10);
}