import consumer from "./consumer";

$(function() {
    $('[data-channel-subscribe="room"]').each(function(index, element) {
        var $element = $(element),
            room_id = $element.data('room-id'),
        messageTemplate = $('[data-role="message-template"]');
        //
        $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000)

        consumer.subscriptions.create(
            {
                channel: "RoomChannel",
                room: room_id
            },
            {
                received: function(data) {
                    var content = messageTemplate.children().clone(true, true);
                    content.find('[data-role="user-username"]').text(data.user);
                    content.find('[data-role="message-text"]').text(data.message.message);
                    content.find('[data-role="message-date"]').text(data.message.updated_at);
                    $element.append(content);
                    $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000);
                }
            }
        );
    });
});


//dans la fonction:
// on vient selectionner grace à un selecteur le chat:"data-channel-subscribe"
// que l'on retrouve dans appelé dans le "show"
//gradce à Jquery, on lit le room ID sur lequel on est actuellement => "room_id"
//on prends le template qffichés dans le message grace à "message-template" dans le show
// grace à "consumuer" on ouvre un websocket avec rails, => navigateur qui ouvre une connexion directe avec Rails => le websocket (similaire à ajax,
// mais contrairement à ajax qui effectue une seule requete et une seule reponse, le websocket c'est une connexion qui reste ouverte
//websocket orienté evenements => navigateur écoute en continue ce qui se passe sur le channel (Room)


//la fonction received détermine l'action Js suite à l'info reçue par le serveur