# ─────────────────────────────────────
# STAGE 1 — Install and Build
# This stage installs everything and builds
# the dist/ folder. After this stage is done
# we throw away all the heavy dev tools.
# ─────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (both are needed for yarn)
# We copy these BEFORE copying all code because of
# Docker layer caching — if package.json and yarn.lock
# didn't change, Docker skips the yarn install step
# and uses cached node_modules. Saves 2-3 minutes.
COPY package.json yarn.lock ./

# Install ALL dependencies including devDependencies
# because we need them to build (typescript compiler etc)
RUN yarn install --frozen-lockfile

# Now copy the rest of your source code
COPY . .

# Build the NestJS app — creates dist/ folder
RUN yarn build


# ─────────────────────────────────────
# STAGE 2 — Production
# This is the final image that actually runs
# It only contains what is needed to START the app
# No typescript, no source files, no dev tools
# ─────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# Copy package files again in production stage
COPY package.json yarn.lock ./

# Install ONLY production dependencies
# --production flag skips devDependencies
# This keeps the image small
RUN yarn install --frozen-lockfile --production

# Copy only the built dist/ folder from Stage 1
# We do NOT copy src/ or node_modules with dev deps
COPY --from=builder /app/dist ./dist

# Your app runs on port 3000 inside the container
EXPOSE 3000

# Start the production build
CMD ["node", "dist/main.js"]

