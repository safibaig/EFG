revision = Rails.root.join('REVISION')

CURRENT_RELEASE_SHA = revision.exist? ? revision.read(8) : 'development'
