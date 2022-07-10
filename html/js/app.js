let container, qInput, qString;
let resourceName = GetParentResourceName();

function lister() {

    container.empty();

    qString = qInput.val().toLowerCase();

    $.each(effects, function (asset, fxNameArray) {

        let result = [];

        if (qString.length > 0) {

            result = fxNameArray.filter(c => {
                return c.includes(qString)
            });
        } else {

            result = fxNameArray;
        }


        if (result.length > 0) {

            $("<a/>", {
                "text": asset,
                "href": '#',
                "class": `no_href`,
                "click": function () {

                    let $this = $(this);

                    $(`.parent_${ asset }`).slideToggle(200, function () {
                        $this.toggleClass('ulClose')
                    });
                    return false;
                }
            }).appendTo(container); // append if recipes not 0 (authItems == true)


            parent = $("<ul/>", {
                "class": `parent_${ asset }`,
            }).appendTo(container);


            result.forEach((fxName) => {

                $("<li/>", {
                    "text": fxName,
                    "click": function () {

                        $('li').removeClass('act');
                        $(this).addClass('act');

                        copyToClipboard((`asset = '${ asset }', fxName = '${ fxName }'`));

                        $.post(`https://${resourceName}/showEffect`, JSON.stringify({
                            asset: asset,
                            fxName: fxName
                        }));
                    }

                }).appendTo(parent);
            });
        }
    });
}


// Listen for NUI Events
window.addEventListener('message', function (event) {

    let item = event.data;

    if (item.subject === 'OPEN') {

        $('#wrapper').css("display", "block");

        qInput = $('#qInput');

        lister();

    }
});


$(document).ready(function () {

    container = $('#list');


    $('#wrapper').draggable({
        handle: '#header',
        containment: 'parent'
    });


    $('#sBtn').click(lister);


    $('#rBtn').click(function () {

        qInput.val('');
        lister();
    });


    $(document).keypress(function (e) {

        if (e.which === 101) { // 101 - E

            if (e.target.nodeName !== 'INPUT') {

                $.post(`https://${resourceName}/exit`);
            }
        }
    });


    $('form').keypress(function (e) {

        if (e.which === 13) {

            e.preventDefault();
        }
    });


    $(document).keyup(function (e) {

        if (e.which === 27) {

            close();
        }
    });


    $('.btnClose').click(function () {

        close();
    });


    $('#day').click(function () {

        $.post(`https://${resourceName}/timeOfDay`, JSON.stringify({
            timeOfDay: 'morning'
        }));
    });


    $('#night').click(function () {

        $.post(`https://${resourceName}/timeOfDay`, JSON.stringify({
            timeOfDay: 'night'
        }));
    });

});


function close() {

    $('#wrapper').css("display", "none");
    $.post(`https://${resourceName}/exit`, JSON.stringify({
        off: true
    }));
}


function copyToClipboard(string) {
    let $temp = $("<input>");
    $("body").append($temp);
    $temp.val(string).select();
    document.execCommand("copy");
    $temp.remove();
}

