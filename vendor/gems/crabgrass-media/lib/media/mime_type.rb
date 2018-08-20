require 'mime/types'

module Media
  module MimeType

    def self.mime_group(mime_type)
      mime_type.sub(/\/.*$/,'/') if mime_type     # remove everything after /
    end

    def self.simple(mime_type)
      mime_type.to_s.sub(/\/x\-/,'/') if mime_type # remove x-
    end

    def self.lookup(mime_type,field)
      (MIME_TYPES[simple(mime_type)]||[])[field]
    end

#    def self.group_from_mime_type(mime_type)
#      lookup(mime_type,GROUP) || lookup(mime_group(mime_type),GROUP)
#    end

    def self.icon_for(mtype)
      lookup(mtype,ICON) || lookup(mime_group(mtype),ICON) || lookup('default',ICON)
    end

    def self.asset_class_from_mime_type(mime_type)
      asset_symbol_from_mime_type(mime_type).to_s.classify
    end

    def self.asset_symbol_from_mime_type(mime_type)
      lookup(mime_type,ASSET_CLASS) || lookup(mime_group(mime_type),ASSET_CLASS) || lookup('default',ASSET_CLASS)
    end

    def self.extension_from_mime_type(mime_type)
      lookup(mime_type,EXT)
    end

    def self.mime_type_from_extension(ext)
      ext = ext.to_s
      ext = File.extname(ext).gsub('.','') if ext =~ /\./
      mimetype = EXTENSIONS[ext]
      if defined?(MIME::Types)
        unless MIME::Types.type_for('.'+ext).empty?
          mimetype ||= MIME::Types.type_for('.'+ext).first.content_type
        end
      end
      mimetype ||= 'application/octet-stream'
      return mimetype
    end

    #
    # perhaps use http://code.google.com/p/mimetype-fu/
    # for all this?
    def self.type_for(filename)
      self.mime_type_from_extension(filename)
      # todo: add type_from_file_command if ext doesn't pan out.
    end

    #def type_from_file_command(filename)
    #  #  On BSDs, `file` doesn't give a result code of 1 if the file doesn't exist.
    #  type = (filename.match(/\.(\w+)$/)[1] rescue "octet-stream").downcase
    #  mime_type = (Paperclip.run("file", "-b --mime-type :file", :file => filename).split(':').last.strip rescue "application/x-#{type}")
    #  mime_type = "application/x-#{type}" if mime_type.match(/\(.*?\)/)
    #  mime_type
    #end

    def self.description_from_mime_type(mime_type)
      lookup(mime_type,DESCRIPTION) || lookup(mime_group(mime_type),DESCRIPTION) || lookup('default',DESCRIPTION)
    end

    def self.compatible_types?(type1, type2)
      (TYPE_ALIASES[type1] || []).include?(type2)
    end

    EXT = 0; ICON = 1; ASSET_CLASS = 2; DESCRIPTION = 3;
    MIME_TYPES = {
      # mime_type       => [file_extension, icon, asset_class, description]
      'default'         => [nil,'default',:asset,'Unknown'],

      'text/'           => [:txt,:html,'asset/text', 'Text'],
      'text/plain'      => [:txt,:html,'asset/text', 'Text'],
      'text/html'       => [:html,:html,'asset/text', 'Webpage'],
      'application/rtf' => [:rtf,:rtf,'asset/text', 'Rich Text'],
      'text/rtf'        => [:rtf,:rtf,'asset/text', 'Rich Text'],
      'text/sgml'       => [:sgml,:xml,nil,'XML'],
      'text/xml'        => [:xml,:xml,nil,'XML'],
      'text/csv'        => [:csv,:spreadsheet,'asset/doc', 'Comma Separated Values'],
      'text/comma-separated-values' => [:csv,:spreadsheet,'asset/doc', 'Comma Separated Values'],

      'application/pdf'   => [:pdf,:pdf,'asset/image', 'Portable Document Format'],
      'application/bzpdf' => [:pdf,:pdf,'asset/image', 'Portable Document Format'],
      'application/gzpdf' => [:pdf,:pdf,'asset/image', 'Portable Document Format'],
      'application/postscript' => [:ps,:pdf,'asset/image','Postscript'],

      'text/spreadsheet'     => [:txt,:spreadsheet,'asset/doc','Spreadsheet'],
      'application/gnumeric' => [:gnumeric,:spreadsheet,'asset/doc','Gnumeric'],
      'application/kspread'  => [:kspread,:spreadsheet,'asset/doc','KSpread'],

      'application/scribus' => [:scribus,:doc,nil,'Scribus'],
      'application/abiword' => [:abw,:doc,'asset/doc','Abiword'],
      'application/kword'   => [:kwd,:doc,'asset/doc','KWord'],


      'application/msword'     => [:doc,:msword,'asset/text','MS Word'],
      'application/mswrite'    => [:doc,:msword,'asset/text','MS Write'],
      'application/powerpoint' => [:ppt,:mspowerpoint,'asset/doc','MS Powerpoint'],
      'application/excel'      => [:xls,:msexcel,'asset/spreadsheet','MS Excel'],
      'application/access'     => [nil, :msaccess, 'asset/doc','MS Access'],
      'application/vnd.ms-msword'     => [:doc,:msword,'asset/text','MS Word'],
      'application/vnd.ms-mswrite'    => [:doc,:msword,'asset/text','MS Write'],
      'application/vnd.ms-powerpoint' => [:ppt,:mspowerpoint,'asset/doc','MS Powerpoint'],
      'application/vnd.ms-excel'      => [:xls,:msexcel,'asset/spreadsheet','MS Excel'],
      'application/vnd.ms-access'     => [nil, :msaccess, 'asset/doc','MS Access'],
      'application/msword-template'     => [:dot,:msword,'asset/text','MS Word Template'],
      'application/excel-template'      => [:xlt,:msexcel,'asset/spreadsheet','MS Excel Template'],
      'application/powerpoint-template' => [:pot,:mspowerpoint,'asset/doc','MS Powerpoint Template'],

      # 'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      #   [:pptx, :mspowerpoint,'asset/doc','MS Powerpoint'],
      'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
        [:pptm, :mspowerpoint,'asset/doc','MS Powerpoint'],
      'application/vnd.openxmlformats-officedocument.presentationml.template' =>
        [:potx,:mspowerpoint,'asset/doc','MS Powerpoint Template'],

      # 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      #   [:docm,:msword,'asset/text','MS Word'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
        [:docx,:msword,'asset/text','MS Word'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.template' =>
        [:dotx,:msword,'asset/text','MS Word Template'],

      # 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
      #   [:xlsm,:msexcel,'asset/spreadsheet','MS Excel'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
        [:xlsx,:msexcel,'asset/spreadsheet','MS Excel'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.template' =>
        [:xltx,:msexcel,'asset/spreadsheet','MS Excel Template'],

      'application/executable'        => [nil,:binary,nil,'Program'],
      'application/ms-dos-executable' => [nil,:binary,nil,'Program'],
      'application/octet-stream'      => [nil,:binary,nil],

      'application/shellscript' => [:sh,:shell,nil,'Script'],
      'application/ruby'        => [:rb,:ruby,nil,'Script'],

      'application/vnd.oasis.opendocument.spreadsheet'  =>
        [:ods,:oo_spreadsheet,'asset/spreadsheet', 'OpenDocument Spreadsheet'],
      'application/vnd.oasis.opendocument.formula'      =>
        [nil,:oo_spreadsheet,'asset/spreadsheet', 'OpenDocument Formula'],
      'application/vnd.oasis.opendocument.chart'        =>
        [nil,:oo_spreadsheet,'asset/spreadsheet', 'OpenDocument Chart'],
      'application/vnd.oasis.opendocument.image'        =>
        [nil,:oo_graphics, 'asset/doc', 'OpenDocument Image'],
      'application/vnd.oasis.opendocument.graphics'     =>
        [:odg,:oo_graphics, 'asset/doc', 'OpenDocument Graphics'],
      'application/vnd.oasis.opendocument.presentation' =>
        [:odp,:oo_presentation,'asset/doc', 'OpenDocument Presentation'],
      'application/vnd.oasis.opendocument.database'     =>
        [:odf,:oo_database,'asset/doc', 'OpenDocument Database'],
      'application/vnd.oasis.opendocument.text-web'     =>
        [:html,:oo_html,'asset/doc', 'OpenDocument Webpage'],
      'application/vnd.oasis.opendocument.text'         =>
        [:odt,:oo_document,'asset/doc', 'OpenDocument Text'],
      'application/vnd.oasis.opendocument.text-master'  =>
        [:odm,:oo_document,'asset/doc', 'OpenDocument Master'],

      'application/vnd.oasis.opendocument.presentation-template' =>
        [:otp,:oo_presentation,'asset/doc', 'OpenDocument Presentation'],
      'application/vnd.oasis.opendocument.graphics-template'     =>
        [:otg,:oo_graphics,'asset/doc', 'OpenDocument Graphics'],
      'application/vnd.oasis.opendocument.spreadsheet-template'  =>
        [:ots,:oo_spreadsheet,'asset/spreadsheet', 'OpenDocument Spreadsheet'],
      'application/vnd.oasis.opendocument.text-template'         =>
        [:ott,:oo_document,'asset/doc', 'OpenDocument Text'],

      'packages/'        => [nil,:archive,nil,'Archive'],
      'multipart/zip'    => [:zip,:archive,nil,'Archive'],
      'multipart/gzip'   => [:gzip,:archive,nil,'Archive'],
      'multipart/tar'    => [:tar,:archive,nil,'Archive'],
      'application/zip'  => [:gzip,:archive,nil,'Archive'],
      'application/gzip' => [:gzip,:archive,nil,'Archive'],
      'application/rar'  => [:rar,:archive,nil,'Archive'],
      'application/deb'  => [:deb,:archive,nil,'Archive'],
      'application/tar'  => [:tar,:archive,nil,'Archive'],
      'application/stuffit'        => [:sit,:archive,nil,'Archive'],
      'application/compress'       => [nil,:archive,nil,'Archive'],
      'application/zip-compressed' => [:zip,:archive,nil,'Archive'],

      'video/' => [nil,:video,nil,'Video'],

      'audio/' => [nil,:audio,'asset/audio','Audio'],

      'image/'                   => [nil,:image,'asset/image','Image'],
      'image/jpeg'               => [:jpg,:image,'asset/image', 'JPEG Image'],
      'image/jpg'                => [:jpg,:image,'asset/image', 'JPEG Image'],
      'image/png'                => [:png,:image,'asset/png', 'PNG Image'],
      'image/gif'                => [:png,:image,'asset/gif', 'GIF Image'],

      'image/svg+xml'            => [:svg,:vector,'asset/svg','Vector Graphic'],
      'image/svg+xml-compressed' => [:svg,:vector,'asset/svg','Vector Graphic'],
      'application/illustrator'  => [:ai,:vector,'asset/image','Vector Graphic'],
      'image/bzeps'              => [:bzeps,:vector,'asset/image','Vector Graphic'],
      'image/eps'                => [:eps,:vector,'asset/image','Vector Graphic'],
      'image/gzeps'              => [:gzeps,:vector,'asset/image','Vector Graphic'],

      'application/pgp-encrypted' => [nil,:lock,nil,'Crypt'],
      'application/pgp-signature' => [nil,:lock,nil,'Crypt'],
      'application/pgp-keys'      => [nil,:lock,nil,'Crypt']
    }.freeze

    #
    # This extension mapping is used to force certain mime types.
    # Usually, firefox does pretty good at reporting the correct mime-type,
    # but IE always fails (firefox fails on ogg). So, we use the MIME::Types
    # gem to try to get the correct mime from the extension. Sometimes, however,
    # even this doesn't work. This able will force certain types when
    # MIME::Types fails or is ambiguous
    #
    EXTENSIONS = {
      'jpg' => 'image/jpeg',
      'png' => 'image/png',
      'txt' => 'text/plain',
      'flv' => 'video/flv',
      'ogg' => 'audio/ogg',
      'oga' => 'audio/ogg',
      'ogv' => 'video/ogg',
      'pdf' => 'application/pdf',

      'doc' => 'application/msword',
      'xsl' => 'application/excel',
      'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'pptm' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'potx' => 'application/vnd.openxmlformats-officedocument.presentationml.template',
      'docm' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'dotx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
      'xlsm' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xltx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.template',

      'odt' => 'application/vnd.oasis.opendocument.text',
      'ods' => 'application/vnd.oasis.opendocument.spreadsheet',
      'odp' => 'application/vnd.oasis.opendocument.presentation',
      'svg' => 'image/svg+xml',
      'mod' => 'video/mpeg',

    }.freeze

    #
    # some types can have multiple names
    #
    TYPE_ALIASES = {
      'image/jpg' => ['image/jpeg'],
      'image/jpeg' => ['image/jpg']
    }
  end
end
