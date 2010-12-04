# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  config.wkhtmltopdf = Rails.root.join('vendor', 'wkhtmltopdf-amd64').to_s if RAILS_ENV == 'production'

  config.default_options = {
      :ignore_load_errors => true
    }
end