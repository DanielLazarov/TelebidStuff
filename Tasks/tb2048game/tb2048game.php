<?php
/*
Plugin Name: tb 2048 Game
Description: Adds a custom 2048 game to the footer of the page. The game will be shown in a modal window when the configured event(s) is(are) triggered. For configuration edit the plugin .php file.
Version: 1.1
Author: Daniel Lazarov <Daniel>
License: Free
*/


function tb_2048_game()
    {

    //Configuration
        $args = array();

		//Regular trigger(e.g. button click)
        $args['simpletrigger'] = '#menu-item-289'; 	//query selector for a DOM element
        $args['simpleevent'] = 'click';				//event on the selected item to trigger the game			
		
		//Trigger for Select menu with options.
		$args['selecttrigger'] = '#subMenu';// <select> element
		$args['optiontext'] = '-2048';	//innerhtml(text) of the <option> element to trigger the game when selected.
		
		//Modal appearance configuration.
        $args['overlaycolor'] = '#000';		//overlay color
        $args['overlayopacity'] = '0.6';	//overlay opacity


        $pluginUrl = plugins_url();

        wp_enqueue_style( 'main', $pluginUrl.'/tb2048game/style/main.css');
        
        $output =  '
    <script>
        (function(){
            function Tile(position, value) {
                this.x                = position.x;
                this.y                = position.y;
                this.value            = value || 2;
                this.image = \'<img src="' . $pluginUrl . '/tb2048game/images/resized/\' + this.value + \'.png">\'

                this.previousPosition = null;
                this.mergedFrom       = null; // Tracks tiles that merged together
            }

            Tile.prototype.savePosition = function () {
                this.previousPosition = { x: this.x, y: this.y };
            };

            Tile.prototype.updatePosition = function (position) {
                this.x = position.x;
                this.y = position.y;
            };

            Tile.prototype.serialize = function () {
                return {
                    position: {
                        x: this.x,
                        y: this.y
                    },
                        value: this.value
                };
            };
            window.Tile = Tile;
        })();
    </script>
    <div id="game-2048-modal" style="display: none;">
        <div class="container-2048">
            <div class="heading-2048">
              <div class="scores-container">
                <div class="score-container">0</div>
                <div class="best-container">0</div>
              </div>
            <div class="above-game">
              <a class="restart-button">Нова Игра</a>
            </div>
            </div>


            <div class="game-container">
              <div class="game-message">
                <p></p>
                <div class="lower">
                    <a class="keep-playing-button">Продължи</a>
                  <a class="retry-button">Опитай Пак</a>
                </div>
              </div>

              <div class="grid-container">
                <div class="grid-row">
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                </div>
                <div class="grid-row">
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                </div>
                <div class="grid-row">
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                </div>
                <div class="grid-row">
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                  <div class="grid-cell"></div>
                </div>
              </div>

              <div class="tile-container">

              </div>
            </div>
        </div>
    </div>

    <script src="' . $pluginUrl . '/tb2048game/js/require.js"></script>

    <script>
        requirejs.config({

            baseUrl: "' . $pluginUrl . '/tb2048game/js/"
        });
        require(["game.mini","easyModal", !jQuery ? "jquery-1.11.1.min" : undefined ], function() {
            jQuery(\'#game-2048-modal\').easyModal({overlayOpacity: \'' . $args['overlayopacity'] . '\' ? \'' . $args['overlayopacity'] . '\' : undefined, overlayColor: (\'' . $args['overlaycolor'] . '\') ? \'' . $args['overlaycolor'] . '\' : undefined});
            jQuery(document).on(\'' . $args['simpleevent'] . '\', \'' . $args['simpletrigger'] . '\', function(){
                jQuery(\'#game-2048-modal\').trigger(\'openModal\');

            });

			jQuery(document).on(\'change\',\'' . $args['selecttrigger'] . '\', function(){
			    var selectBox = document.querySelector(\'' . $args['selecttrigger'] . '\');
				var str = selectBox.options[selectBox.selectedIndex].text;
				if(str === \'' . $args['optiontext'] . '\'){
					selectBox.value = \'\';
					jQuery(\'#game-2048-modal\').trigger(\'openModal\');
				}
			});

        });    
    </script>
';

        echo $output;
    }

   // add_shortcode('tb_2048', 'tb_2048_game');

    add_action( 'wp_footer', 'tb_2048_game' );
?>
