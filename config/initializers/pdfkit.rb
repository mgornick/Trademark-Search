# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  config.wkhtmltopdf = Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s if RAILS_ENV == 'production'
end