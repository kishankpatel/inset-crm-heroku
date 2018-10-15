# module Mail
# class BccField < StructuredField

# include Mail::CommonAddress

# FIELD_NAME = 'bcc'
# CAPITALIZED_FIELD = 'Bcc'

# def initialize(value = nil, charset = 'utf-8')
#   @charset = charset
#   super(CAPITALIZED_FIELD, strip_field(FIELD_NAME, value), charset)
#   self.parse
#   self
# end

# # Bcc field should never be :encoded
# def encoded
#   do_encode(CAPITALIZED_FIELD)
# end

# def decoded
#   do_decode
# end

# end
# end
