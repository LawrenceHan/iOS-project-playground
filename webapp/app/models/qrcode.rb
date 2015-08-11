class Qrcode < ActiveRecord::Base
  mount_uploader :code, FileUploader

  validates :title, uniqueness: true

  after_commit :generate_code, on: :create

  def code_url
    "#{ApplicationHelper.host}#{code.thumb.url}"
  end

protected

  def generate_code
    if code.blank?
      host = APP_CONFIG[:protocol] + APP_CONFIG[:host]
      tmp_path = Rails.root.join("tmp/qr_code_#{self.id}.png")
      tmp_file = RQRCode::QRCode.new(host + "/qrcodes/#{self.id}").as_png.save(tmp_path)

      File.open(tmp_file.path) do |file|
        self.code = file
        self.save
      end

      File.delete(tmp_file.path)
    end
  end
end
