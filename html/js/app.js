let container, qInput, qString;
let resourceName = GetParentResourceName();
let adjust = {};

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

                        let dScale = parseFloat(adjust.scale).toFixed(1);
                        let dr = parseFloat(adjust.r).toFixed(1);
                        let dg = parseFloat(adjust.g).toFixed(1);
                        let db = parseFloat(adjust.b).toFixed(1);
                        let da = parseFloat(adjust.a).toFixed(1);

                        copyToClipboard(
                            `
                            FOR ECO_CRAFTING AND ECO_COLLECTING:
                            dict = '${ asset }', 
                            name = '${ fxName }',
                            loopedAtCoord = { 0.0, 0.0, 0.0, ${ dScale } }, -- [xRot, yRot, zRot, scale]
                            loopedColour = { ${ dr }, ${ dg }, ${ db } }, -- [r, g, b]
                            
                            NATIVE:
                            scale = ${ dScale }
                            --SetParticleFxLoopedColour(fx, ${ dr }, ${ dg }, ${ db }, 0),
                            --SetParticleFxLoopedAlpha(fx, ${ da })
                            `
                        );


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
window.addEventListener('message', event => {

    let item = event.data;

    if (item.subject === 'OPEN') {

        $('#wrapper').css("display", "block");
        $('#slider_container').css("display", "grid");

        qInput = $('#qInput');
        lister();
    }
});


$(() => {

    container = $('#list');


    $('#wrapper').draggable({
        handle: '#header',
        containment: 'parent'
    });

    $('#slider_container').draggable();


    $('#sBtn').click(lister);


    $('#rBtn').click(function () {

        qInput.val('');
        lister();
    });


    $(document).keypress(e => {

        if (e.which === 101) { // 101 - E

            if (e.target.nodeName !== 'INPUT') {

                $.post(`https://${resourceName}/exit`);
            }
        }
    });


    $('form').keypress(e => {

        if (e.which === 13) {

            e.preventDefault();
        }
    });


    $(document).keyup(e => {

        if (e.which === 27) {

            close();
        }
    });


    $('.btnClose').click(() => {

        close();
    });


    $('#day').click(() => {

        $.post(`https://${resourceName}/timeOfDay`, JSON.stringify({
            hour: 12
        }));
    });


    $('#night').click(() => {

        $.post(`https://${resourceName}/timeOfDay`, JSON.stringify({
            hour: 1
        }));
    });


    //https://api.jqueryui.com/slider/
    let $fx_scale_v = $('#fx_scale_v');
    let $fx_r_v = $('#fx_r_v');
    let $fx_g_v = $('#fx_g_v');
    let $fx_b_v = $('#fx_b_v');
    let $fx_a_v = $('#fx_a_v');


    $.post(`https://${resourceName}/nuiSync`, {}, data => {

        adjust = data;

        $fx_scale_v.html(adjust.scale);
        $fx_r_v.html(adjust.r);
        $fx_g_v.html(adjust.g);
        $fx_b_v.html(adjust.b);
        $fx_a_v.html(adjust.a);

        $("#fx_scale").slider({
            min: 0.1,
            max: 5,
            step: 0.1,
            value: adjust.scale,
            change: (event, ui) => {

                adjust.scale = ui.value;

                $.post(`https://${resourceName}/changeFx`, JSON.stringify({
                    name: 'scale',
                    value: adjust.scale
                }));
            },
            slide: (event, ui) => {
                $fx_scale_v.html(ui.value);
            }
        });

        $("#fx_r").slider({
            min: 0,
            max: 10,
            step: 0.1,
            value: adjust.r,
            change: (event, ui) => {

                adjust.r = ui.value;

                $.post(`https://${resourceName}/changeFx`, JSON.stringify({
                    name: 'r',
                    value: adjust.r
                }));
            },
            slide: (event, ui) => {
                $fx_r_v.html(ui.value);
            }
        });

        $("#fx_g").slider({
            min: 0,
            max: 10,
            step: 0.1,
            value: adjust.g,
            change: (event, ui) => {

                adjust.g = ui.value;

                $.post(`https://${resourceName}/changeFx`, JSON.stringify({
                    name: 'g',
                    value: adjust.g
                }));
            },
            slide: (event, ui) => {
                $fx_g_v.html(ui.value);
            }
        });

        $("#fx_b").slider({
            min: 0,
            max: 10,
            step: 0.1,
            value: adjust.b,
            change: (event, ui) => {

                adjust.b = ui.value;

                $.post(`https://${resourceName}/changeFx`, JSON.stringify({
                    name: 'b',
                    value: adjust.b
                }));
            },
            slide: (event, ui) => {
                $fx_b_v.html(ui.value);
            }
        });

        $("#fx_a").slider({
            min: 0,
            max: 1,
            step: 0.1,
            value: adjust.a,
            change: (event, ui) => {

                adjust.a = ui.value;

                $.post(`https://${resourceName}/changeFx`, JSON.stringify({
                    name: 'a',
                    value: adjust.a
                }));
            },
            slide: (event, ui) => {
                $fx_a_v.html(ui.value);
            }
        });
    });
});


function close() {

    $('#wrapper').css("display", "none");
    $('#slider_container').css("display", "none");
    $.post(`https://${resourceName}/exit`);
}


function copyToClipboard(string) {
    let $temp = $("<textarea>");
    $("body").append($temp);
    $temp.val(string).select();
    document.execCommand("copy");
    $temp.remove();
}


