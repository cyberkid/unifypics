addCheckHandlers =->
    $('.set label').click ->
        check = ($(this).find('.check'))
        image = ($(this).find('.thumb'))
        if ($(this).parent().find('input').attr('checked') != 'checked')
            check.addClass('selected')
            image.addClass('selected')
        else
            check.removeClass('selected')
            image.removeClass('selected')
            $(this).focus ->
                
                check.css('visibility','hidden')
            $(this).blur ->
                $(this).unbind('hover')


$(document).ready -> 
    if typeof fb_user != "undefined" and typeof flickr_user != "undefined"
        loadsets = (api, picker, target, load_message) -> 
            $.ajax
                url: api
                type: 'get'
                dataType: 'json'
                beforeSend: (xhr, settings) ->
                    $(target).html('<center><img src= "assets/loading.gif"><br>' + load_message + '</center>')
                success: (data) ->
                    $(target).html('');
                    if data.hasOwnProperty 'fb_albums'
                        set['fb_albums'] = data['fb_albums'][set['id']] for set in data.sets
                    
                    if data.hasOwnProperty 'progress'
                        set['progress'] = data['progress'][set['id']] for set in data.sets
                    
                    $(picker).tmpl(data).appendTo(target);
                    addCheckHandlers()
                    
                    #add select all handler
                    if $('#select_all')
                        $('#select_all').click ->
                            if ($('#select_all').attr('checked'))
                                $('.sets input').attr('checked',true)
                                $('.sets .check').addClass('selected')
                                $('.sets .thumb').addClass('selected')
                            else
                                $('.sets input').attr('checked',false)
                                $('.sets .check').removeClass('selected')
                                $('.sets .thumb').removeClass('selected')
            
        if $("#sets_list_template").length != 0
            loadsets('/flickr/sets','#sets_list_template', '#sets', 'Loading your flickr sets')
            
        if $('#inqueue_sets_list_template').length != 0
            loadsets('/flickr/inqueue_sets','#inqueue_sets_list_template', '#queue', 'Loading photos in upload queue')
                    
        if $("#uploaded_sets_list_template").length != 0
            loadsets('/flickr/uploaded_sets','#uploaded_sets_list_template', '#done', 'Loading uploaded photos')
            
            
        
        