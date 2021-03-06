json.array!(@photos) do |photo|
  json.extract! photo, :id, :gallery_id, :image, :gallery_token, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :description
  json.url photo_url(photo, format: :json)
end
