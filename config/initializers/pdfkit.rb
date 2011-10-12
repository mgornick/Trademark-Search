# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  if Rails.env.production?
    config.wkhtmltopdf = Rails.root.join('vendor', 'wkhtmltopdf-amd64').to_s
  else
    config.wkhtmltopdf = Rails.root.join('bin', 'wkhtmltopdf-0.9.9-OS-X.i368').to_s
  end

  config.default_options = {
      :ignore_load_errors => true
    }
end
