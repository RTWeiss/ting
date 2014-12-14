(($) ->
  Boker =
    init: ->
      self = this
      Bootup = ->
        self.siteBootUp()
        return

      PageUpdate = ->
        self.sitePageUpdate()
        return

      $(document).on "page:load", Bootup
      $(document).on "page:update", PageUpdate
      return

    siteBootUp: ->
      self = this
      self.initSemanticUiTools()
      self.initAvatarPreview()
      self.initUploadAvatar()
      self.initCheckXiamiInfo()
      return

    sitePageUpdate: ->
      self = this
      self.initGetXiamiInfo()
      self.initCloseMessage()
      self.initGetNotificationsCount()
      return

    initSemanticUiTools: ->
      $(".user-avatar-upload").popup()
      $(".ui.selection.dropdown").dropdown()
      $('.ui.sticky').sticky({offset: 100, bottomOffset: 50, context: '#main'})
      return

    initAvatarPreview: ->
      $(document).ready ->
        AvatarPreview = (avatar) ->
          if avatar.files and avatar.files[0]
            reader = new FileReader()
            reader.onload = (e) ->
              $(".user-avatar").attr "src", e.target.result
              return
            reader.readAsDataURL avatar.files[0]
          return

        $(".upload-avatar").change ->
          AvatarPreview this
          return
        return
      return

    initUploadAvatar: ->
      $("input#user_avatar").css "display", "none"
      $(".user-avatar-upload").click ->
        $(".upload-avatar").click()
        return
      return

    initCloseMessage: ->
      $(".message .close").on "click", ->
        $(this).closest(".message").fadeOut()
        return
      return

    initGetXiamiInfo: ->
      $('.album-pic').on "click", '.playBtn', ->
        self = $(this)
        play_icon = self.find('i.play')
        pause_icon = self.find('i.pause')
        $player = $('#player').get(0)
        $audio = $('audio')

        if $audio.attr('data-xiami_id') is $(this).attr 'data-xiami_id'
          if $player.paused
            $player.play()
            $('.rotating').removeClass 'stop-rotate'
            play_icon.removeClass('play').addClass 'pause'
          else
            $player.pause()
            $('.rotating').addClass 'stop-rotate'
            $('.pause').removeClass('pause').addClass 'play'
        else
          play_icon.addClass('spinner rotating')
          $.get 'http://inmusic.sinaapp.com/xiami_api/' + $(this).data('xiami_id'), (data) ->
            if data
              $('.stop-rotate').removeClass 'stop-rotate'
              play_icon.removeClass('spinner rotating')
              $('.rotating').removeClass 'rotating'
              self.siblings('.image').addClass 'rotating'
              $audio.attr 'src', data.songurl
              $audio.attr 'data-xiami_id', data.id
              $('.pause').removeClass('pause').addClass 'play'
              play_icon.removeClass('play').addClass 'pause'
              $player.play()
            return

        $audio.on 'ended', ->
          $('.rotating').removeClass 'rotating'
          $('.pause').removeClass('pause').addClass 'play'
          return
        return
      return

    initGetNotificationsCount: ->
      if $('#unread-count').length > 0
        setTimeout (->
          $.post "/notifications/count", (data) ->
            if data > 0
              ( if data > 99 then '99' else data)
              $('#unread-count').addClass('red').text data
            return
          return
          ),30000
      return

    initCheckXiamiInfo: ->
      $('.check-xiami').click ->
        $('#song-errors').removeClass().html ""
        s_id = $('input#song_s_id').val()
        $btn = $(this)
        $btn.addClass 'loading'
        if s_id.length > 0
          $.get("http://inmusic.sinaapp.com/xiami_api/" + s_id, (data) ->
            $('input#song_title').val(data.title)
            $('input#song_artist').val(data.singer)
            $('#song-errors').addClass("animated zoomIn").html '<div id="error_explanation"><div class="ui success message center">检测通过, 填写分享内容后即可提交</div></div>'
            return
          ).fail( -> 
            $('#song-errors').addClass("animated bounceIn").html '<div id="error_explanation"><div class="ui error message center">未获取到该歌曲的相关信息</div></div>'
            return
          ).always ->
            $btn.removeClass 'loading'
            return
        else
          $('#song-errors').addClass("animated flash").html('<div id="error_explanation"><div class="ui error message center">请先填写虾米 ID</div></div>')
          $(this).removeClass 'loading'
        return
      return

  window.Boker = Boker
  return
) jQuery

$(document).ready ->
  Boker.init()
  Boker.siteBootUp()
  return
