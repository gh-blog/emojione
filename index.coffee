through2 = require 'through2'
fs = require 'fs'
vm = require 'vm'
File = require 'vinyl'
_ =
    defaults: require 'lodash.defaults'

{ emojione } = require 'emojione/lib/js/emojione'
# emojioneFile = "#{__dirname}/node_modules/emojione/lib/js/emojione.min.js"
cssFile = "#{__dirname}/node_modules/emojione/assets/css/emojione.min.css"

module.exports = (options = { }) ->
    options = _.defaults options, {
        imageType: 'svg'
        useCDN: yes
        minifyCSS: yes
    }

    # sandbox = { }
    # vm.runInNewContext (fs.readFileSync emojioneFile), sandbox

    # { emojione } = sandbox
    emojione.imageType = options.imageType
    # used_emojis = {  } # Index by unicode character?

    processFile = (file, enc, done) ->
        if file.isPost and file.$
            $ = file.$
            $root = $.root()
            $root.html emojione.toImage $root.html()

            $('.emojione').addClass 'emoji'
            # @TODO: inline some styles to fix RSS huge svgs
            # $('.emojione').attr 'style', 'max-height: 1rem; max-width: 1rem;'

            file.contents = new Buffer $.html()
            file.styles.push '/styles/emojione.min.css'

        done null, file

    through2.obj processFile, (done) ->
        # @TODO: push all the emojis
        @push new File {
            path: '../styles/emojione.min.css'
            contents: fs.readFileSync cssFile
        }
        done()