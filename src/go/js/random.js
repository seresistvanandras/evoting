
var inp;

$( document ).ready(function() {
    //jQuery time
    var current_fs, next_fs, previous_fs; //fieldsets
    var left, opacity, scale; //fieldset properties which we will animate
    var animating; //flag to prevent quick multi-click glitches

    $(".next").click(function(){

        console.log($("#response").attr("href"))
        console.log("NEXT");
        if(animating) return false;
        animating = true;

        current_fs = $(this).parent();
        next_fs = $(this).parent().next();

        //show the next fieldset
        next_fs.show();
        //hide the current fieldset with style
        current_fs.animate({opacity: 0}, {
            step: function(now, mx) {
                //as the opacity of current_fs reduces to 0 - stored in "now"
                //1. scale current_fs down to 80%
                scale = 1 - (1 - now) * 0.2;
                //2. bring next_fs from the right(50%)
                left = (now * 50)+"%";
                //3. increase opacity of next_fs to 1 as it moves in
                opacity = 1 - now;
                current_fs.css({
                    'transform': 'scale('+scale+')',
                    'position': 'absolute'
                });
                next_fs.css({'left': left, 'opacity': opacity});
            },
            duration: 800,
            complete: function(){
                current_fs.hide();
                animating = false;
            },
            //this comes from the custom easing plugin
            easing: 'easeInOutBack'
        });
    });

    $('.form-check-input').on('change', function() {
        inp = $('input[name=radios]:checked', '#msform').val();
    });


    $(".submit").click(function(){
        console.log("SUBMIT");
        return false;
    })

});

function myTest() {
    console.log("fosss");
}

function use_api() {

    $.ajax({
        url: "http://localhost:8080/selected",
        data: {arg: inp}
    }).done(function (data) {
        var arr = data.split('</body>\n' +
            '</html>' +
            '');
        console.log(data);
        $("#response").attr("href", arr[1]);
    });

}
