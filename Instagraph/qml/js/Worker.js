WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;
    if (msg.commentsModel) {
        var commentsModel = msg.commentsModel;
    }
    if (msg.suggestionsModel) {
        var suggestionsModel = msg.suggestionsModel;
    }

    if (msg.clear_model) {
        model.clear();
        if (msg.commentsModel) {
            commentsModel.clear();
        }
        if (msg.suggestionsModel) {
            suggestionsModel.clear();
        }
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {

        if (feed == 'homePage') {

            // Suggestions
            if (typeof obj[i].suggested_users != 'undefined') {

                for (var k = 0; k < obj[i].suggested_users.suggestions.length; k++) {
                    suggestionsModel.append(obj[i].suggested_users.suggestions[k]);
                    suggestionsModel.sync();
                }

                model.append({"suggestions":true});

            }

            if (typeof obj[i].media_or_ad != 'undefined' && typeof obj[i].media_or_ad.injected == 'undefined') {

                obj[i].media_or_ad.video_url = typeof obj[i].media_or_ad.video_versions != 'undefined' ? obj[i].media_or_ad.video_versions[0].url : ''

                obj[i].media_or_ad.carousel_media_obj = typeof obj[i].media_or_ad.carousel_media != 'undefined' ? obj[i].media_or_ad.carousel_media : []

                if (typeof obj[i].media_or_ad.image_versions2 == 'undefined') {
                    obj[i].media_or_ad.image_versions2 = {}
                }

                obj[i].media_or_ad.suggestions = false;

                model.append(obj[i].media_or_ad);

                if (msg.commentsModel) {
                    if (obj[i].media_or_ad.comment_count != 0) {
                        for (var j = 0; j < obj[i].media_or_ad.max_num_visible_preview_comments; j++) {
                            commentsModel.append({"c_image_id": obj[i].media_or_ad.pk, "comment": obj[i].media_or_ad.preview_comments[j]});
                            commentsModel.sync();
                        }
                    }
                }

                model.sync();

            }

        } else {
            if (feed != 'searchPage') {
                obj[i].video_url = obj[i].video_versions ? obj[i].video_versions[0].url : ''
            }

            obj[i].carousel_media_obj = typeof obj[i].carousel_media != 'undefined' ? obj[i].carousel_media : []

            if (typeof obj[i].image_versions2 == 'undefined') {
                obj[i].image_versions2 = {}
            }

            obj[i].suggestions = false;

            model.append(obj[i]);

            if (msg.commentsModel) {
                if (obj[i].comment_count != 0) {
                    for (var j = 0; j < obj[i].max_num_visible_preview_comments; j++) {
                        commentsModel.append({"c_image_id": obj[i].pk, "comment": obj[i].preview_comments[j]});
                        commentsModel.sync();
                    }
                }
            }

            model.sync();
        }
    }
}
