CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS "recipes" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "title" TEXT NOT NULL,
  "description" TEXT,
  "instructions" TEXT NOT NULL,
  "prep_time_minutes" INTEGER,
  "cook_time_minutes" INTEGER,
  "servings" INTEGER,
  "image_url" TEXT,
  "source_url" TEXT
);

CREATE TRIGGER trg_recipes_updated_at BEFORE UPDATE ON "recipes" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "recipe_tags" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "name" TEXT NOT NULL
);

CREATE TRIGGER trg_recipe_tags_updated_at BEFORE UPDATE ON "recipe_tags" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "ingredients" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "recipe_id" UUID NOT NULL REFERENCES "recipes"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "quantity" TEXT,
  "sort_order" INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_ingredients_recipe_id ON "ingredients" ("recipe_id");

CREATE TRIGGER trg_ingredients_updated_at BEFORE UPDATE ON "ingredients" FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE IF NOT EXISTS "recipe_tag_map" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "recipe_id" UUID NOT NULL REFERENCES "recipes"("id") ON DELETE CASCADE,
  "tag_id" UUID NOT NULL REFERENCES "recipe_tags"("id") ON DELETE CASCADE
);

CREATE INDEX idx_recipe_tag_map_recipe_id ON "recipe_tag_map" ("recipe_id");

CREATE INDEX idx_recipe_tag_map_tag_id ON "recipe_tag_map" ("tag_id");

CREATE TRIGGER trg_recipe_tag_map_updated_at BEFORE UPDATE ON "recipe_tag_map" FOR EACH ROW EXECUTE FUNCTION update_updated_at();