class AutoIncrementGlobalizeLanguagesId < ActiveRecord::Migration[6.0]
  def change
    execute "
          ALTER TABLE globalize_languages ALTER COLUMN id SET NOT NULL;
          ALTER TABLE globalize_languages ALTER COLUMN id SET DEFAULT nextval('globalize_languages_id_seq');"
  end
end
