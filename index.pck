GDPC                 �                                                                         T   res://.godot/exported/133200997/export-45c2fd9952f64ecaf7682c7d1a6f75e1-SplitTab.scnp�      �      �}���n':Q¡lÔ    X   res://.godot/exported/133200997/export-96f04d1941a93a42547eb49c5900d128-MainTheme.res    �      B      �����ɤ�i J�F��    X   res://.godot/exported/133200997/export-e26ba1523f1e66f414fed51ed52c7402-calculator.scn  �            *<���/r�L���a�    ,   res://.godot/global_script_class_cache.cfg  p�      �       ������jUPP=)�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�7      �      �̛�*$q�*�́     L   res://.godot/imported/junegull.ttf-4aaf4c1832ae6d952e8acc0d8b3b8931.fontdata`E      l      ���H�	~Bp�}a�       res://.godot/uid_cache.bin  ��      �       ����ZQ�<�%d�N�       res://MainTheme.tres.remap  ��      f       �$LB)�J�R��k�d       res://SplitTab.gd   p�      �      
Ϡ^8jC��	n1���       res://SplitTab.tscn.remap    �      e       b��j2��z�3|���       res://calculator.gd         �      �-�.�g��Y9ό	       res://calculator.tscn.remap  �      g       �_7L����M%c��0�u       res://icon.svg   �      �      C��=U���^Qu��U3       res://icon.svg.import   �D      �       ���\$G~������       res://junegull.ttf.import   p�      �       �L�ͻ���f'��˛       res://project.binary`�      �      [�SC�!�T5�\��ċ�                extends Node

var raceDistance: float = 10000 #user set
var lapDistance: float = 400 #user set
var realTotalLaps #calculated    Decimal
var totalLaps #calculated        Rounded up
var smallLapLocation = 2 #user set (if needed) 0-no small-lap 1-beginning  2-end
var smallLapDistance: float #calculated
var lapsComplete = 0 #updates
var goalTime = 60*30+52 #user set
var raceActive = false 
var currentTime = 0 #updates
var splitTime = 0

var splitDistances = [] #calculated
var splitTotalLog = [] #updates
var splitLog = [] #updates
var goalSplits = [] #generates pre-race
var aheadBehind = [] #updates

var onPaceForAvg = 0#calculated
var onPaceForLast = 0#calculated
var avgSplit = 0#calculated
var avgSplitNeeded = 0#calculated

var splitTabLoad = load("res://SplitTab.tscn")
var splitTabArray = []

func _ready():
	$PreRace.visible = true
	$ActiveRace.visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_up") and totalLaps != lapsComplete:
		if raceActive:
			Split()
		#else:
			#goalTime = 60 * (60 * float($Temp/HBoxContainer/LineEdit.text) + float($Temp/HBoxContainer/LineEdit2.text)) + float($Temp/HBoxContainer/LineEdit3.text) 
			#raceDistance = float($Temp/HBoxContainer/LineEdit4.text)
			#lapDistance = float($Temp/HBoxContainer/LineEdit5.text)
			#if goalTime > 0 and raceDistance > 0 and lapDistance > 0:
				#StartRace()
	if raceActive and totalLaps != lapsComplete:
		currentTime += delta * 10
		splitTime += delta * 10
	$Temp/LapsComplete.text = str(lapsComplete)
	$Temp/LapsTotal.text = str(totalLaps)
	$Temp/SplitTime.text = TimeFormat(splitTime)
	$Temp/Time.text = TimeFormat(currentTime)
	$ActiveRace/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/AvgSplit.text = TimeFormat(avgSplit)
	$ActiveRace/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer2/NeededSplit.text = TimeFormat(avgSplitNeeded)
	$ActiveRace/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer3/OnPaceAvg.text = TimeFormat(onPaceForAvg)
	$ActiveRace/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer4/OnPaceLast.text = TimeFormat(onPaceForLast)
	
	$ActiveRace/VBoxContainer/HBoxContainer/Time.text = TimeFormat(currentTime)
	$ActiveRace/VBoxContainer/HBoxContainer/SplitTime.text = "Split: " + TimeFormat(splitTime)
	if lapsComplete > 0:
		$ActiveRace/VBoxContainer/HBoxContainer/Distance.text = "Distance complete: " + str(splitDistances[lapsComplete - 1]) + "/" + str(raceDistance)
	else:
		$ActiveRace/VBoxContainer/HBoxContainer/Distance.text = "Distance complete: 0/" + str(raceDistance)

func Split():
	avgSplit = currentTime / (splitDistances[lapsComplete] / lapDistance)
	onPaceForAvg = avgSplit * realTotalLaps
	avgSplitNeeded = (goalTime - currentTime) / (realTotalLaps - splitDistances[lapsComplete] / lapDistance)
	lapsComplete += 1
	splitTotalLog.append(currentTime)
	aheadBehind.append(splitTotalLog[lapsComplete - 1] - goalSplits[lapsComplete - 1])
	splitLog.append(splitTime)
	onPaceForLast = currentTime + splitLog[lapsComplete - 1] * (realTotalLaps - splitDistances[lapsComplete - 1] / lapDistance)
	if smallLapLocation == 1 and lapsComplete == 1:
			onPaceForLast = currentTime + splitLog[lapsComplete - 1] * lapDistance / smallLapDistance * (realTotalLaps - splitDistances[lapsComplete - 1] / lapDistance)
	splitTabArray[lapsComplete].totalText = TimeFormat(currentTime)
	splitTabArray[lapsComplete].splitTimeText = TimeFormat(splitTime)
	#splitTabArray[lapsComplete].aheadBehindText = str(snapped(currentTime - goalSplits[lapsComplete - 1], 0.01))
	#splitTabArray[lapsComplete].aheadBehindText = TimeFormat(currentTime - goalSplits[lapsComplete - 1])
	if aheadBehind[lapsComplete - 1] >= 0:
		splitTabArray[lapsComplete].aheadBehindText = "+" + TimeFormat(aheadBehind[lapsComplete - 1])
	else:
		splitTabArray[lapsComplete].aheadBehindText = "-" + TimeFormat(abs(aheadBehind[lapsComplete - 1]))
	splitTime = 0
	if lapsComplete == totalLaps:
		raceActive = false
		print(aheadBehind)
	print(avgSplit)

func TimeFormat(time):
	var minutes = floor(time / 60)
	var seconds = snapped(time - minutes * 60,0.1)
	if seconds < 10:
		seconds = "0" + str(seconds)
	if minutes >= 60:
		var hours = floor(minutes / 60)
		minutes = minutes - 60 * hours
		if minutes < 10:
			minutes = "0" + str(minutes)
		return str(hours) + ":" + str(minutes) + ":" + str(seconds)
	return str(minutes) + ":" + str(seconds)
	
func StartRace():
	totalLaps = ceil(raceDistance / lapDistance)
	realTotalLaps = raceDistance / lapDistance
	if (totalLaps == raceDistance / lapDistance):
		smallLapLocation = 0
	else:
		smallLapDistance = raceDistance - totalLaps * lapDistance + lapDistance
	if smallLapLocation == 1:
		splitDistances.append(smallLapDistance)
		var i = 1
		while i < totalLaps:
			splitDistances.append(splitDistances[i-1] + lapDistance)
			i += 1
	elif smallLapLocation == 0:
		splitDistances.append(lapDistance)
		var i = 1
		while i < totalLaps:
			splitDistances.append(splitDistances[i-1] + lapDistance)
			i += 1
	else:
		splitDistances.append(lapDistance)
		var i = 1
		while i < totalLaps - 1:
			splitDistances.append(splitDistances[i-1] + lapDistance)
			i += 1
		splitDistances.append(splitDistances[totalLaps - 2] + smallLapDistance)
	avgSplitNeeded = goalTime / realTotalLaps
	var j = 0
	while j < totalLaps:
		goalSplits.append((avgSplitNeeded / lapDistance) * splitDistances[j])
		j += 1
	var tabInstance = splitTabLoad.instantiate()
	splitTabArray.append(tabInstance)
	var world = get_tree().current_scene
	world.find_child("Chart").add_child(tabInstance)
	j = 1
	while j <= totalLaps:
		tabInstance = splitTabLoad.instantiate()
		splitTabArray.append(tabInstance)
		tabInstance.distText = str(splitDistances[j-1])
		tabInstance.goalText = TimeFormat(goalSplits[j-1])
		tabInstance.totalText = "-:--"
		tabInstance.splitTimeText = "-:--"
		tabInstance.aheadBehindText = ""
		world.find_child("Chart").add_child(tabInstance)
		j += 1
	$PreRace.visible = false
	$ActiveRace.visible = true
	print(splitDistances)
	print(goalSplits)


func _on_continue_pressed():
	goalTime = 60 * (60 * float($PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer4/Hour.text) + float($PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer4/Min.text)) + float($PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer4/Sec.text) 
	raceDistance = float($PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/RaceDist.text)
	lapDistance = float($PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/LapDist.text)
	if $PreRace/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer3/Switch.button_pressed:
		smallLapLocation = 2
	else:
		smallLapLocation = 1
	if goalTime > 0 and raceDistance > 0 and lapDistance > 0 and raceDistance >= lapDistance and raceDistance / lapDistance <= 1000 and raceDistance <= 100000 and goalTime <= 86400:
		StartRace()


func _on_startsplit_pressed():
	if raceActive == false:
		raceActive = true
		$ActiveRace/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer5/StartSplit.text = "Split"
	elif lapsComplete < totalLaps:
		Split()
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://calculator.gd ��������      local://PackedScene_5adfr          PackedScene          	         names "   A      Calculator    script    Node    PreRace    visible    offset_right    offset_bottom    PanelContainer    HBoxContainer    layout_mode    Control    size_flags_horizontal    size_flags_stretch_ratio    VBoxContainer    custom_minimum_size    Label    theme_type_variation    text    horizontal_alignment 	   Control2    Label2 	   Control3 	   RaceDist 	   LineEdit    HBoxContainer2    LapDist    HBoxContainer3    Label3    Switch    CheckButton    HBoxContainer4    Hour    placeholder_text 
   alignment    Min    Sec    HBoxContainer5 	   Continue $   theme_override_font_sizes/font_size    Button    Temp    Time    LapsComplete 
   SplitTime 
   LapsTotal    avgsplitneeded    paceAvg 	   paceLast 
   LineEdit2 
   LineEdit3 
   LineEdit4 
   LineEdit5    ActiveRace 	   Distance    size_flags_vertical    ScrollContainer    Chart 	   AvgSplit    NeededSplit 
   OnPaceAvg    OnPaceLast    StartSplit    _on_continue_pressed    pressed    _on_startsplit_pressed    	   variants    &                         �D     "D                 @@
         �A,      HeaderLarge       split calculator             Input race details:        @      Race Distance:       ?     �?      Lap Distance:       Partial Lap Location:       Start       End       Goal time:       hr       :       min       sec    *      	   Continue       B      dist       Lap 
          A
      A       ���>      @      Avg split:       Needed split:       Pace (avg):       Pace (last):       node_count    h         nodes     �  ��������       ����                            ����                                      ����   	                 
   
   ����   	                             ����   	                                   ����   	                       
   
   ����         	                       ����   	               	      
              
      ����         	                       ����   	               
                    ����   	          
       
   
   ����   	                
             ����   	                            
       
      ����         	                      
             ����   	                      
       
      ����         	                             ����   	                 
   
   ����   	                             ����   	                                   
      ����         	                                   ����   	                             
      ����         	                             ����   	                 
   
   ����   	                             ����   	                                   
      ����         	                                   ����   	                                         ����   	                             ����   	                                   
      ����         	                             ����   	                 
   
   ����   	                             ����   	                                   
      ����         	                                   ����   	                         !                       ����   	                                "   ����   	                         !                       ����   	                                #   ����   	                         !                 
      ����         	                          $   ����   	          (       
   
   ����   	                (       '   %   ����   	            &                (       
      ����         	                       
      ����   	                           (   ����                         -          )   ����   	          -          *   ����   	          -          +   ����   	          -          ,   ����   	          -          -   ����   	          -          .   ����   	          -          /   ����   	          -             ����   	          5             ����   	                 5          0   ����   	                 5          1   ����   	                 5          2   ����   	                 5          3   ����   	                            4   ����                   ;             ����   	          <       
   
   ����         	          <             ����   	          >       
   
   ����         	          >          )   ����   	                      >          +   ����   	                >          5   ����   	                >       
      ����         	          <             ����   	      6          D             ����   	                      E             ����   	          F       
   
   ����         	          F       7   7   ����   	            6          H          8   ����   	            6          F       
      ����         	          D             ����   	                K             ����   	          L       
   
   ����   	                       L             ����   	               !      "       L       
      ����         	                      L          9   ����   	                      L       
      ����         	                K             ����   	          R       
   
   ����   	                       R             ����   	               !      #       R       
      ����         	                      R          :   ����   	                      R       
      ����         	                K             ����   	          X       
   
   ����   	                       X             ����   	               !      $       X       
      ����         	                      X          ;   ����   	                      X       
      ����         	                K             ����   	          ^       
   
   ����   	                       ^             ����   	               !      %       ^       
      ����         	                      ^          <   ����   	                      ^       
      ����         	                K          $   ����   	          d       
   
   ����   	                d       '   =   ����   	            &                d       
      ����         	                      conn_count             conns        *       ?   >              f       ?   @                    node_paths              editable_instances              version             RSRC   GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dkcgcvcfp14vo"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                RSCC      ��  	  �  �
  �	  M
  K
  
  :  �  E  ]
    (�/�` �? �v B��1 @�"��	�:�G�Ʊ"���VqMJ�n$���m��:p=��X��ۨ!�k7��omo)��RJ�spX�P�snlD�H��'�,;����U�	dPP�Y�D�,_�8p2g��Z��pm��6R�BZ	B9��𠖳�M�7\Y�d,=�+eS�8s��o:�9���ǐf�ɸ�U!me��J:��(�t8�L�:����6g��N�4Q'uT%J�U9�9�i��,��3RF��ϖ���.������Q��J*'%��%iE�l�l� o����dR4�F����,��`I�4-�DRf�����Fu�o`ĉ�H�r2[X%�dP�^�����M���C�UI���75�$(�@�����9�o��u�N�G:X�4r��a��R���7p,z8�3R�+e6p����
G���L�|��>�� ���������O�͝N�:� uz��>�����>= }���a2�m��dz���g6=�Y73��	a*x��t9}Fa�u�.�tv&v:���oA_П�]���Z���������_�.f
��n�C&�I?_E�ޞ�a�1�|q���~ܥ{ع�WE\;>�d,��b�
8�F�(�5~:��/s��D.���̟̔� ��J�˳�5N~p8���@�Oz~h�
���?�$����	$���䗹��l�5� �6��[����wܚ�Zm��W���kM�~4��cecT�h52<~<M��D����m����*?��d��@��F��p��I����wq�V֘E���/�LT�x�Ź��*?!��ւć1�?�?�Bh�Vz��b|��2�׳��m+ƕ�\Tk��j|��5W���S|����J��s�K)�7ߛiŹ^[���bJ���VZq��z���k��^{��Vz�RKm���|�����Ģ�懙`ΉaFMjR�_~�� .��A��lnh�D�h"�)Ѥw�M/1��� >����_���ꇚ���]��W���nw�=�:ѡJ�r��f~��8(���柝��:�3]M}]���B_G@����Pf�u�t��w�J?t���O�@_Wqtׄ����u3vv��w����=T�K������̦�΢L7B<�����ט�[�?e>�걻��|f�W3��ؕ��{��7ѣ���7�ן���̞�yna���[�����Hz�����YH-�ۭzY���j��e���������.����۳��6���V���meB�YW�u=��fU�}�({�۶�~KZ�����a���{��Vm���^�u��u�u��V�?j�ik�e��ϻ:�l�7�4ne��k����[Z�=���9k�3�U뭯w�u���ku��\q�g[k���k���:{��m3������~�������׌��U���^ַ֤�i���)K�iݘ�u��j$km���לq��V\q�X�J�X�׋)��֫�q�kZ������|5�n���V�/�ߋ��W�q�6k���,��AffDD�I����@&��`U&�!"b�(��(�h3�F���G����ɣ�Bi���]�:�*�k:���QH"�g>���·��6�YG�6�����!�c�����^;�	���ġ!:���Ƿ���7s��Ԗ쟽"^�Cil/�EG�1!�2��;*�"���Y�����dN-���/tćJE[,�؁�R�]�����ds�{���:���Zcs\%��v�R��G�j�B/|�7�,���"��h�q�Y}[�e~�@��t���.���G�.L�L�(Јc�,��m���k���͇��]�!��$���Q�o_#\�;ٗa�1�W-~�7�G�$ i@�g������G5T��W�F���1HΏ��(��Wi��Ȋ�R����_��3��Sgf9\E=GU�P��6,�z�+�{�~����&��.%�����A}Ä#Ǭo'��	���G�=�<�45^:^�����`"�$QZn<Ƨ�U�����ǙuY��x����`�jr i�o�H��
�m�� �"�#;O0�;2E�*�|��/&{v�$(�/�` MD ��|CP�)�<.� �b���k���K����/���{㺙 0Zd���Yk��n�������RJ)���۾�)���;�ok�u�3�U}+�s�Y_��[Uz�=�Y�
�9+�Ә���SrNƨ��UUUw�Y��lKl��]�\k���VW��u�.�r�_�
߬s���p��ԭ,����jE��O�R�R�J9U6c�o��������_���(�VK��2Ғ��ck���y+u���〈�u/�r[���,JgWSj��>�J�:UkY�N\�EQ���SilUJU��휓�2J�kQUY�ekŮ���-�uR��j��v�IM�Zkek��U5���IM �J'I'ZU��v�K�i�t��C�[Q9�LZ���r���l�&�z�����J�עr�sR:i�r�i����VӜ�UQ���ʩ��ޡ�c�Τ��$/;;�Ng�9%��B������eU�N˲:mM�R��zEM93���ZM�3��SN:-iM:g���}��/˲Zm4+��^�:k��h���<P������q��}�u�����iG�c���ĬN�\vŶ�mܶq[t��M�u��}]Ȳ�o�n����(�ɪ���z�䛻my��q���y4��n�8n�۰9���:����mf��	���2έ�;�Yvo51��l۶�Z�>U�|7�dF��7����E?��
p�ݲ,�۰L3P�����e��mܶ�-��iۦi���䕭���}{Zм¶̗um��X���,m�0�0)�����V/mmQ޲�IQK.�rrTl�ؾ>Ywqw�,��/lc�w�,�0캰�Uk[�Vjm!�eYQ_�l]]�u޴i۲,K{;�WY�����ײBle�����K�ڶv�z�}m�7�vv�
tJ���*�I'+����ui��6���bV��ު��mZ��N��֫S��9���僼�����P�����\(��I�Gy4Ό������D�23@�b�*9�(�G@Q>UHQ�:�ʩ�t6�o�H�� �h��2�2�ʈzfG3#Ɇ$�b�3$��h��I��c�m�8Xfr>���H�`�@�H�iS�X&�qGQ�9��Ȉ��+J��`P!eAc,]3��e�e˶�2EP�M�FT�ńY�D ��������MvA��e&QՀ�rQ���.�!�	��u���Q����{C�Чff�x���x"�$r]g- A�ͣ-��D0��`���Ϩy��	A�'��>]�]+z>�5�5����������[���^ݾ�y��zK���*����3�B��W�m#��m�F�n�g[,�`���O�}���1������?��m��0�гE�~�ò� �0�U*A �W��v��u_ֲvT
��<��d�o�7F̝ b�[��\�x��{\��q<��������8S������e��\�O^����Q��(�Q��(�Q�4HIߐ�!�DJ��*)�]JW@�/QH`����O��39&����7rF.?�e�J��8C�G�DL�&�B`xx��Rz'����SrI���"��|���7���xB���\�^:����w���p.��x��M��N�/q%�ĉ���F܇���pN��>�O�	O�(���p^¡������7\��p7�ť��k8w�6\�_�_��3�r<��q8����O�j��q3N����`<��.�Ź���Y܊Gq&^ćx�� ��{���7���[��/���|�K����;����O�Y���/�|�c��[� �UN� |ʥ<�Q��ۼ�4'}�2}��1t��s�Ã��;��ڳc�����o_O����(�b�	DD���1`�#Es� �:b�$���k��Qe�T��$[�΢������HglS.�Y���%M�<�1���I'����>U!i�oL�a��Z<	�n��"n�a��`�񒘟�@�9S���������|���K� &:�T(%ϫg/ 3�,����y5���F �O�830Mv�E<�apL�4����.�	,���A_(�8�@yZ���-�2�����}D,��89Fr����Qa��F-1�4��&i�V�o�4�.���e�nq�\T��pl������ hԃc�?��ěG�_|��E-���-�t��>/�'L��\o] ,'?J�%�9~�
(�/�` �T ��� W�TUg{�ْWE��"s�4[��-B�w�a��R�*�1V��%4��6��0�Q/X�-C�m\��{��Ob`���9�����dK����%�7b��1���R�T°��n�5�ԕh�ŕ�F���Rr����ʈ �����|��;X�>���\}��|����i�٘������##t��AZ��"��io��e}���?����w��>O�Y�7{��{�c�5�9p�� ��h+&��l2(n�ڶ�z˷U��^o1�R*�˝t�F���Ɔ����\���˒|�E����I~���`��O�c��tY����id��	���G���V^|�_�k�I~^�������Z>>���O�֌_���f����O�4��a;��0��]�������i��j���o�����,4��V�x.p���7��[3D�>"@�֭��
`kf�g�'������i��F����7��w��[Ծ�<�ށ*���娈�j0�Ҩ>��Q}�̗C�iT[�͢i�ۖ�Y���j��,	�/:��o�����q
>�w��߿W�.��x������������s&�~)9���w'�}��W�#�����{w���u�=��׹{����}��UwO~����fE���f߬�7��.������G!�L @#T �ȶ��UE���JMTN(�RI
��rBY�N��i�f�"34�P6D��,��M�P�f��h��m��mE�h�Vj�(�Ԓ
�l�\�EZ�N��	�޹8�"WX�����h*�\��r�ܲ�H�o6��ov�}�sN�ˎ�9�����iJ��4���^�CJ�h�4dHKkZZ� <�a�otN�'��	R�)-y��Ǡ�5L�ZN�*\�����t1����
K���ނ��S��}������t�����;x�>m�A�.��m��]�����i���$!������}� � l$h��i:�M����h��r�M�����Mb9�R�F�ً�43�<�H+(<��%Z��p�hleZ9tM^���dt[(#YXhĸ�	%�G"��[��5�h-��ZId
�Q(� �j�э?��:�����������=r�X�^q�U�9�p0�㵷Z��"|��(��,́���ђ���I��� W��\����i�nS���4�7�E}?�
�P�3|��1J���L4GQ%D�!���,4SR�<�P���#!��f�(�cJ5���Y-
�-�l�Erd���5fN�����(.n'�1��+��&4�Z���������0�A��3����0ٓ-aq�l��־���k\�/���U��1bGE�<��3@ �L�,X��A��3��+_8Y,�S������x>���W��<������O?>�����F>�����'r��	��H��!�#>�� 	l�
+4�K8^N[�7�߬���"7���y7���u�<��׹y����|��U7Ϳ��O�n�
�s��1�������Ԙ&����"AQT=Z;D��)���,��f�E�$��"sRq�Q���������9n��p-�Zh����rZ���n/�a��a�Ӵ��� �M�i �$^� �_����Y�x9]L�r:�^��!1�+:�8X��Vz<rv��p؅Z��ϒo���l}���o7����'E{Ya`�f �/�U����+��(!sI9��^bN)/+L��j�mnz`%��Vb�&����O-(Cї_���<��'��{�|/�����//?{�������>�Nn�����4�1�G��ap��6=h݁χ�lE�]N'[q�����m�}��ur(��v�='1݊��!SU4'5�B5N���N�:zY��R�'�ƂS1��©�T*8�ˍ�N���n�^�
=97V.��ܒ��..�P^
�hz*��@�:	��_������_��_��쯧�n䯟�N>�"GQG���u=���9z���}��UGI�ϟ+���w4��H���JNR��@�Q�+%r��,�X��dfR�R�3��=x��h
�(]��c��I�?�V$W��-i�:�^+�^{#��N���������0�B2""""�&Iab�1&�`�t4I���"��]�E�~w2�L�)7@I�Q[K|����5�yΚJh��b�e@}��=��dY:������b�5�6��3t��!�k����ON�@�lF�����p��w�i�S�:��ŏ�/��7�U5:7�_?ӆC�oN��Cg�����#}�4H�6+*_f6/_�/�������^�����b�
Y�hG��U�]�6m9}�(.s��xQ*	�3o:����󃄶%��l��<ߞ=��G)��}Di��$E�u��k�ݾ8h����w�գ֖�,<��!��bm�ґ&��}� غ�i_JS�J��"P>�" T�Q�3��3�o���B#e��؆�� 9�?�V���5����`k���F�11Us��4��ȸ����Q�'}��k�A*�܉���|�2r����?�*���4�=��H��a�nXq�k"�U�Ҧ�}��R��/��/q"̱Ռ��Q��.���[{.��QT(S����_����P����O����q��>���Ib�!B���t/��c'��C��M�n��C�F1�7�s�iJ�(g5��Xm'U}��C�''}�׸����#oڏ[5(�/�` UL �HU�RQgc%��I��p�y�x8)��|��o�g��9�tH��2
�������'�ImJ��5���`����k�6=����۟�s�)���L���{'��ޥ_�ՙ_peeй��M�喪�ab�����"K.*R/LL`�R.$�v�J�
gl7�Pukɵ�V�L�3�*E�ZMfe�1m��'��}��3eV�cA�Y[�������N7I��>k�]_�T�>]��	��Ȯ���Ǯ}�ZǮm��Ůo��]�L���v�d׹=-v�/x��H���ھ���|o+�j�&�l�UYu{Z؄VMd�AV}���αjܪiV�j֪I��L�ة�:���������گ�q���Rm��4�b��
O��KZ�m����N��Fc~F�đ$Cg1#��J��g=:�z��.�� ���^�e��ZӑaC�0b�d⁢.Ԩ���!�� 5�h���;�Ծh5�$���Ծ>%�24;�J�K\�`��,��Qν:{��֭|A�����<�:5i�������$!�(-$�2�@1�^$��r$2�!�
�.�X�X�b�H�lfY��R���fϭ��j~W�����6���d	hĈ�NMY�����̐����AQ��XU[���J?���x�:4��ٔ2O8h9d�	Q�JYZ�	�LC���XL�,��r��=e3֬eSm�����w�N��@�TT&CU�J䨰��g[/0Ղ���}��G��2�;��CJ<ɏ�Ⱌ'N�B�!Z�`B��N0-qXXp�<I_I���Y�h��XvMI�l}ו�M3��`�U��J����K�XMa8�����;���ůMh�"�Y���>ױ���],~[ܵx�(�dq���~�߹.Wgs�����bi
��N���Y�Gu>?_]��ks����{�9~�O��<�?�c��8��ĴW�5m�T��dV&��XIfeh��'2���[�d�$%;c�}}đ�D)�T�����ag"��L1V���b6#��8�G�`���
�i�am�@��U1d��R������j���}���Ȧ�l�Ǧ}lZǦml�Ŧo�vm��d:�&�wڥ��wU�k��`t1��J&�����qK���,%2K����"�`�s��s\cd ��zQ�+\.(�9Τ35ՙ�U�ϾLq����`�����=���9Ȟo��c�9���3͞c���3iO������[sB�%S�ĖX0���T��b
�V� �|$M6�&rR1���V����ľ8"'�p�B07��Τ���3ZmRY�Z�l6�b��Jh?9u�[���S�V��N��N���.򷐿���o����߷�]��I���N��0ߝE�]a�+���n2�[b_��pE#�t:�^�����*O�:6�����o��6/7͓l�|�,Y<��7��X<���i�Y��8iQܡ�|W�wm��p��xxJ���� %�ĥEF�D�H蠄�0�� 4��]={ʬ��������7N�%6r`/I�H���$S� 
����r�Hw���L8�N�Ψsk�;}w�/�R}��wU}_�Nû��UrjX--����;J8oG��d�(R�H(Pd��&x�D" ��t�����`הDZ�͢V+�k����^]�+�N���R\bL@��O�l )뱠Y�*�V�
y9H��;Ze�������R4v��̢Ft�ܚ�]O�uT:����N�S��]S_>��)q�S�^ȗVMMc��(Tg�
�;�d�k%R��<'�y��o>��y��q��|�9�s���O�:���|w�/�����Ɛ�`#]��d���0�C"#""�$I:�D��� %.��*�&I��;�FT2���U'	iR7����Z�91Q��v�!z,Go�A�<������8��oM�!?@tp�BȒ���[��B{��Yݵ�Ǜ������F'v|���5�[�C�<�S[S�.�/+8��*t�&V���dEZc�D����v#\:��Z\[Ť�� ����>����aT�5�/Z�+�!��^6�/��"�K�U��v��[}V���%֝L1MW���*������������z��5c;o��Sb��8�K� �EJ��X����0�s�f?k'ѓ;L�:�M o�������:=$�_TѢp�R�<]�����n7XA"�P��~ژ�Ej;�W�TVD[[����x՗&��*�"�X2����_.��¦��z��[���٭�Ѵ�6O�-�pV7��!�cK/���q,#Ǐw��z��{ʆM͜�l���Ӭ�p��Į�1-�et�ޙ�g����/֟X`��?�?��":~쁞ib�DD�@,�A
u�@�,fX�0m��_~�u�+�^��mk@PX$]�*&G��"k�����~�	����D]��5ثv0�¤1xi��5�Q`j�����j��W��4ժX�P(�/�` R ���S`�1�K�,w��ɕ��p�УO�`��Q}+�8�y����C��K���4�C��P����W��m�"�A����@�����V����L������ʨ���Ȩ�F4j�(�eF����u�(��EMNRJ���S��T<4�j��a;"�ê�"�f+LQ��Sc�xT:�;/�"5*Tu(��)��b76H��NU5vEs��ӫ;�;u:�o��G��J-Vk�m�c��Ķ���Sζ�l[�m���-�f`�K�`�I��m�m�c=F�+q^Q�N�+qމ����;�r�-��_����]�}��R�M��J����^�2�z��zE����b�F � #����P5)�4�$ٜ�Q:(P�����2�#ԃ(&3R�fI���&Twԓ���:�q�B��p�m�?|����p/�w9���R'r���A��G��^���5=��U����X�ΚW�^����W˵�@.�q�@�&ED����ШV�(y�W��&N���dٱ#K�"PuÁ7��@<#p��7n8P�z�3���hgW�;�����jٿ�r�-��_����]쥂�d̵�W�5��\0-Z`�lƊ�����IL����)�K�d+�.*VOM��tx�й��ZK�e�j%�I.�C��;t%��9�O���-�N�Mih�cS8��4tl���+ǟ�'4��J�f���d�3$��p�0���Ϫf!Gf�ȈP#Ԭxf�X����ܨ�#��O��
Zu�$�^Q��4���SS�:M?=:���Z��^oIӊ�
_:=?6����ֳ�遆t���ͪ�&c@9�N�t�ٜnT�Z�ө}���W��Q@����)�E�7FӍ"A���v_tqYH<#��n8��"ף|���2�)�<"��;6�>mw��Ԇ��' �hh��v��P�ٸ^0��(�����Y�O<��N��?ڰ�@'T�@����89-)���J@������Jj��Q�怹^67��h���#�$��H� n�s���z~���{	<�{�xj-�-1�n=�h/4�ngR����TRψ���Y@9X�Ɔ����'�^q�>�^����+�P���Q{9��W�y�F��W*y�#�<���Wy��"��WJ�A���;�x'�q���8^��N�W2��v�ܽ��+����;o�2�+�s�g�Q�e^1�fD���'�4��Ot�(���(�͞W��;y^Y���?��u���J ��|' �d�b�;s������N*���W�rOuxʿ�zeͼy�K�KW��
�]:�Wn����S)�)���(e>��%�>�i�A�����E!P+ZE��.�#�Cs(O��Gy��c<��2��c8�;���4�����:����q�&'��V�1a5���/�����3f<O�HC��9�YKGg��f9���J�
��L�d��8A=��J����7�9�~��S��m��ig��$�Lx��HФI8����ϯ��HjD�M?2���j��h���1W�vB�	=���r7���}^q��m0���<� E�%gDB AG /]���>J-�έi�u�馽R��Nf��މ�+�;?9x'��-��,"�wR9����9�ȿ9������7}�c	��w� H2z��+�W�^)#��ܼ�b�����lM�;u�)��3���{�@W�����t�w>�+Н�J+���yel@WR�Н��!�b�YE�:Е`^�Iw2���ПX��,@g]�DW��;��J'�R����$��S%��O��S���t�>e`�.�S�i�>��S�>�t������t'���}�2�Сό��8S1ԝ��<�;}t%LWz�0�)])DW9ԟ��ΦWN�N0�ыW�tE.�Ʌ��;�x��+����F���ѝs>�J4�L�L�"�D��xgGL#ޑ	��w�J!^I�ox�a��	������&��+��Nޑ���;]x����+[x�
����^9�;=x�	���;5��c�#�����+��b�wVy���$�S�̈��H�&�R
A���9�&I�|rb�l#E�W��a��ߝ��%j�e�����! 2��Gp{<�r�ު��~ �*��j��7�g���σS�8���m�Y3`s�w�G��ۋ��[LɿRj6�����8��k�9O9����S儹���eR��lD���sDi��k`D@�� ҇���y7��P��u�F�ӑ��ݨ�����S��F�{x��<~8��XG~���[��9��o��V��zϢ��2O�j�6�qZ���5�:�5k�2��׀y"
�=e�K�8s>��d�� �N�Ĭ<ˍ�����O��0h%�H8Q�&wOG�'��Tt}�]�ި�^W^��:�p�wzl�,�өI���܉0��3Qb�QڑzS4H(�i��r����AǴ&l�|S{���,�0!�[�8����!�?Cc�
f ?��=��Ƃea���ցf^��!�����Q��%��@��>�gLa!vO��w�CR���G�ft	�&u.ʲO��3��/�ʒKc>��cl6��U��I����7 `d��(���/���*��g��5J�&�I!�h�P(�/�` R z� UpV�H�g���<ə�2H��t�١��wz���*������}U�v�H��n7��߃��;C�7̊7.��-��NU� ���d��P3 ��f�0�LK�=LӼ���hR⨚᠚�Z�Lf��J�ɀ����t,�ʥ�AZ�l3����S)�}��[���s��u����ƕP*GK(�ÀO�O��)R(��L�PhH�)�6��&�ХR	������qT��Z\�3Wĭ۸u�qƒ�6���uV�XuUm�����n�qSU��6��ĢRm�����\�ƙ�M���cӮ��mVuU�(�,��jJՕ���6��V-1�rg.˝�xՖm�0���XuG���R��mU�r[<��#N��T�u[1c+��V�t~)h%�_%�����>�4���_�	4�����_#<�_��)"H���ί������t~o����47�ծ��McU�_��f��l��������v-�����:�[מ��/������������^�\��f��fq�[RD�>�Ϡ	�/�g���[�3�>�D<�D<�K<�C<�C<�J<�@<�@<���o�`�3����3X����9w����[^� ���{�����g�������[zo<�4���>��,�ق�Wԩ�0a�+RC�P��+�P�;�z�1A�V	��o�C�*˙*��DÒ՝r�Y�y#&Œ���#�j܍&U��%���ާ��,��˫��gs�� ���W�	�`N�N�%�,kM�l��5��̂Ϭ����{���	6���T������̬���2UkS�i��B�E������`�z��r�vXQ&i��V�Ԏ |�^W�u_�'��%Ji�J4�=eʔ(L�l�Ze�!;&���T�D�������,kt��B
)Li���)-U%C������:�)bb��� ZP��0~�֖��8�!��R�q�a��1����LQ��q�y!/w��� ?$���)Kj��d2�(p@�q�4s()�B�B���UwWt]��F���m�&"V:/$�5��=�$Ƥ"�ğ(�J�%1#�pK'y�*z�J`�ʲ$C`KL++��-���#�4�d�;�3]��-�VO�Y&�NcC��g��4��~*��i�����UL�Ó���~�n��.���3X>�B�^���y���5R�1���Գ�hy��Y�S�'ڼ�U�aS�����`ȊU$��>���a�6�wˑ��5험�<�nކ�_���|��Or�?7��on�u�摸i>u��(�����3�>��3�>�p���l���{�O�W�����M}��+W�Ӊ]�74Fq�a�;a��\ d�K��Q���j��ʣ���门ul�7/���l�N��{8���;��]ʹ;9w&�����;�s�9����s��y�~:w��]�ٚ�~�F�,mZa晃�CE���L�/^	�&��Z*�a����jҖ�E-���B0? �qR��y�픩�w5R�,�`7����T���
���g�t��S��6�_Ϡ���<���r�H�{���W��'���ޓ��Ͻ���{0�� ���z.����i�R���q��p�O�m��~���7��$?���A~���]?�y���3HO���>^��;�x&���x��_?��8��AW�u=��� κ�66+A�o�����L���Z�N�BS(E������F��Z�}�@�T��4��X���^&Y	����  i�4	�����%�^��ͦ�h�8!&Q���aNcO@�g �\�1��ꙍyr�F���C�gm��#�O
od["D�#���ADI��x2������@=���Ĉf��f�z�)�����W?�m��BeQ.2;��i�9O��H�t�l9����_Nc�R�ӍlP��TaI��_nd���}Z��RU��mÄ��Nc]�Y�3+��A��������3�H�̦�8z#��N��r��S�1��/T[uG����k�� َ��Q�3���wr�L����9z Gos��ѓG/z���g���μ��� ƐcFFDDD$I�6��!ļ�01�h$IRH#�^��lx���٥N�J周��9��>�����L�S��2#����8���n����	�d����`�{(ba��#��"{�w���	�[�&�z���}��)^ۛ/�����\����d6s�c}�S"�F�#�8t~��뮕��+v���	�6�r�(7l+;��b�6F���#k4������"��۲�Zud�?��"�2�����߲�
	ߚ��r�e=�&� ���)X��h��1>�x�3&_���W��TK�{�����)qJ�-hs��y��z��u�3f�M��[��󜑎��=9%x��P��[M���E=>h��Q9�}�[�=U~�䙩'Hl�QF�/�8��=(m_���Tї��y�86��ϾB٧�ɢ��Z����T��6����}�zjP���w�)d+3J�?�2dG���W`���Jn\'A�����ę)]��'(�w�$��kz 鉿�HJ+,�l�6��;���O�{��B]�CΡ�Sɔ����U�sn��F��yc�8('.�B7M��(�/�` �O *��T�V�4��$��S~s
t�+���7�]؀���W/^}�'�'N|E�NFX��kb��<^|�Z���4�(�{���--�����e
���״gY�9e=�/.ǹ`��P^[Eb[l��^w�T�^>���N���Ɍ����T��fu �I_M]�W״)�V-ۺ'�Wh�O��Ӻ5�׵���cY���w�Y���0V睫{�z���q�,#�DOy�aA��3��"�r��9�|?�����
~��	����W����7���<��s�|�)ϱ�g|��9�� ����푼����텼=�����2o������N�m�e��4�sz��qu	�׌����4���8_��s�P�-�?��4�L"J/70#�b f�\^|4�,WK���B�u90�'�i\�K���vUY���K��^���G��G^>����@^~��˼��˓/�}�	r_މ���FV>˸g�>����<�P��������\���/�O����*�HU�A�Ɔ�U�A��C[�-Qdi�KY��WO�s��Y���lV�N�J�f�(,E!ψ��L��D`�m�S*���#�I�Rv�HY��4�Pd( 	���ҍNݨJ9r�Q,}:U��&#�\�]tXꒊ�)���a�E;����1f&R(,E^��۶�Y��0D2���j�LR��|�FC|:
�+�	�����t>]ӫ*#�:�^:,�ɗ��M��{?��bfƧɘ}ZV�\� �s���Pd=4�{U���3��,���x��xƣt��~��۹�����[^^Z|�{U��jf=�5G7��"{�b\0L9wX�y>�s��y�8���">���i`ɒ�������\p�Q�lӈ`�A���m���6ML�6d鎒ޗ�:Υ���c��P���A�i�3�T([J�O#�`[#V�$+�8~<�
t�T��vϗmϩ�9&z�/�y�v$�~��C�v!���w\�̵�\;yM���{�Y(���^�]6��� ��\U����p�)\������q������z�ՋW��x#S���Yf>c�s�xNxNx�:�^��@�5�'6G��NJ�YrBn��;Ih Q�I��D�����S�UM?��t�
���F�K����]�0�^��1��H�h�l+�m\ߪ�*��ދ��'�����ɹ��sW��/�O䌞��k1C��.E��<�|NN�zEQ+��l�l�4��s��m%rL%LxR���\&�?�_Q��l=ϵG���dҠGR�C��=�K��Z�4���L�:ŢZ��EW���"���f>t�󵮗
=S�a�^:�M�?j��*���1ħ(�P@؝yXZ�y��n�:�u�8�I�x1�D�`� ��;�()"��x�F0�$��M�Eֵ�R F�g�#����p��F�<#\G�0��f��U�t��(����cV��^=��Dճ�jW5�y��x��J10��8��b4�ېc�P��Uw	"z��U����1�$����$k��tz帑d�&'$�D��4��%N<y(	D��Z��4��Ф瑝C0	w���и�tqM+|���$��H#�a�0䕺@!��p��^��q}��Az��b�3f��3^Y_ͧ������wX���0��чw�&
u!�x���P�C��y��7ܰ�t���"��Ý�d���Б�U>
<hJdG�m�l�����9�=�0��,�r/�
��55�`���(�D[-�d��hR����(����i�6�9T*kY�:T��itmt������Ĉ�3����UM=$=���Y�Zˉ�h�ւ�3�ц���Y��̉�h�6��-���S��}���Cz{��]Qt=URF�����x��)\ݰ���u_�˽5��Y�8z>�z�j��kyƯgY�+���,ƌBfFDDD�$IaB�HF���T7����}��~�9���[�:�D���I8W�aTvgS��U�eu�YYD���X�&lZ��pCt��:*ƍ�Ǟ��w������^�M.ui�����.����tlV��lCp�� �[Q���3|���}�K�x뢃��݇�oMx�YY�0���m����l�1�h�	@T�=��������O���=���m8"�Ź�����{m��b�|X�A��a�[*�w�<��{A��]��Տ ~��ho���e�{��Q��R�!��X^Z��ך��poC��!�I�Pވ|o��,�hot�� yΔ�Z@L�$��B9����֏�QF��!�A���1w���ȑ��ܕ<T�3��tRVO�Q)�D8/����' ��:/�Ņڮng���+ Rp�H�b�}�a�c��.𭿻i 	�$������I�y5�̃Bo�-}���*��љ	)#�6��|���o0ɔ�O����:
aU���)cl�1Ay^��	����t�����\�o'0��ewH��jG�����'ݷ�2��vnw���-�6�Ͻ� !�f/k$~Z�����Hi�p���b�Q,���(��a��$�u�o�ѿ����n��Դ,���(�/�` �A Jz�H�ZUk<M��3��q�a�ȃ�.m4h��A�J������������c	v`=�w�t]�����_�:��o�Pk����^rΩ<�i:��_���t�ӟNg:=����w��N}�s����K?����e��e2鳋�.Mq;ŝ�#�nQ�[��UѬ��S�s���\��#>�����ύ��|~���ڑS���Ϗ����۩�-z�u*7G���WGN��ql�bs�Km��9��	6'n�ۜ��y�hʼe�E~��n��-k�%r��Gʝ��ܹ��z\M|��껙J&�g'�<"T��l�SHU�~}���u�w�ˮ��ɈQ�� s7���	f�2gi:˹ԙ�e��K�>3�т��,*/qh�SeBAH��|3��ѧ���q��s��ܲ�[$���T���4���}0��BBLL������%Jg����`���3ͼE����֩���a�*�?���'��������έ�\3wF2w��znn�L%��ul6��:W��5���rhi[k4'͹���jΚ��e[�"��U
b�[Vu{�g� ��V����CY�Ů�Bbݢk��.�P�bmnٚ�e˶R�n��ݼ�yK(c��:�|7��u5bo�T�@�p@�����;@A(�I	hv�;C=��*�)�'����[o�.� ����ғ����S��"1(��3S���ҥ�J�а,

�\Z,���t��2�E>�? �{����)�[��7��q��ſQ�[��O�f�w����7�_n�qn�qn�s7�;���s����-�w;��y.�r����>稨�YB|0R�n������!\[+� �`NKA�k�h�M���v�P�f9��= adb)�����Z�b�ūC��Y�b_�����S�u��x]��#^�z����׍���~{]_��c����q*���E}?�����U]�n��T2��0�(�$m��~^�]�I��`�d0L���J,��$���|O&��yì,$B��H�}��"f�L%�� 9+QBLp�zp��g�֒�nγ����j�@
۪݀	��`5���G	�Da5�V���:�-K Kǻv�O��T��)�-Z�"K�u;ߴ~������1e2�f�Q��\j����8�26���+���2�D�q�zp�=x�A��rDF(!<��	����Z�QU�u�cu��Xj��ՓV7���mU}ɪ:��=s�
���EW��Uo�{���u��U|����4��3��@�Ko��nQ�[c�[u*��^o�~qo����ӽ�����{��M�7ջe���,�-;����G ���u�h�fs���4�Vs4�Aq8���nn�}�P�-��Sk7h�̉�!Y$�s�칝2�E�H?"8A��} K�6=6(jki1�F������ҮNPH�FC���?�@��.f1�`oY ߽7�9[m(q��,{18���pA�+��AL��yc3,IM���ܼXBZ�Z�	�u���Z�K��$����U�����j��а�U߁��0�CddDDD$i�1a�!c�{��y�eČ2���gˬ,��|IϦYH�4I������� ���C�5�9�KwyR��l�Bɖg���s;�g=wې$n�|����1���I�'�]���X��j�|�0�h�y�C�R�vE2���@��2���.����g»*/ϓҧ���]����O�hO�n"����7�
�';������zs2aMʌ��Yc�m�@�ʳ������˵:y@S�����^��K[3%M�~�d�ɗ)C-�}��b(��6۳$�@7�o�Y�I�u�Ǜ#8�JEĈ�g�A?~�4�Ўr�ޔt�� f�¼&ގ�&ބO�>ﵗT��,�{��4gtD2�;)S��f�������+]���=��i%Jx/�"���I��K#��.>˥]�%&�it���Z��2t����=C��"�%�ƹ�Qgqߦ�q]�}�F��&,�%s[������jN��i6c���%g4�NY_U�Y$zz�NbM�+�D낅�C�����yb%%{�7�қ�kŃ3�ԮL�F��,���4����yj(�/�` �3 j\tG�q�$@�\m��K�<^�k#�/6w��;�s\��n6��U�*U@7}�����Ưn�~w�ϵ�I�EM�'� 89kc��Vyl�VeV�J����u��w"����w�! :�=co{��;���ڛ��9{��=�]څ %�[Gt�g�D�#q��(a�f3M[NG����G�P�ZXb"((D�����ܩ'�0�rٴhr��\NH�K�v�Ċ�Bq�U��Z �ژgU����S���b͜�n���~w��EI�|�L�CI�ƭK�oJ���9��!�����#�#�j�^*�k��`c����b}�b�XLG�X��x��@�`E��q�>q烙a�}�l�&�b�q�0��ㄺ�؅�Ȏ.dt��"�7�}uX+�v�:tۺ�Lsy��^��@+���@�uʍ,Е�z�`�FMͳ�n��
��+��/�8�?A=��v��R��Z򆸔*P�7�Ak%A�走pT
2�Re�� 0` yU!���,�b-�l�U�9��r&uI�Ke�)��.�]v�:ܷ˛�$��_���Cc}��eC-���U�`�R�q�1�A���ʗ�E���R�x�@@y-b�� �	e�}��GB����(� j4��ИD��c����ĝ@�����ω���Ř.VUH�U�	έKa�]M��-� ���|S�t�w�
���R�uE�ݹ{��+׫uվ ̗�4y��]L~b��g����&י|fr�$���R���:"{������8���!�p����9<���Fu��Ǵa��a�\�rDī�y�'�u�v1|���U��+pT��i��3��*S�v����w�t�׹�����r=ˑ}1ba�bT��p���wg�ͯ��D��k��b���=��Fw0���3���Yף���.��-x��;� 	�4�J�^9t���@?���|���f���7��KdB�� tC�~b���GG���#Ҹ�psC����W˪����p��νoغ��Mm��5.wq���G\���
�;�\���a��B.�/h���/���|S�o���1ϵ[7�$l��פ�C��2\�T�
%��FYk�2��GZP( 42�x(��)0�� Z#a�
�X �ښk��M��$��bѪi�ق��s����u�ٟ�Z��(�U���&5�;�[��s���1)SF�IR�t`!"�y��4	b�$�D�#%��ĉ�T2��X� [X�Jۊ�E�Y����{���OL.$�I�1pP�n��2m�,z�'*�1b���(��ޜzﮒ���C�
��r�I(Ӑ)��Jh�p�L���$��Q�eA��O�82z��ƨv�*XQ������6�Ӓ�����:J�%�4�r�����4��x�|*�n߃-^5>6��u��"��Y�{{&(��J��/���˹�Yp`?�HT�z4��(�3��H�x&�7;9b����e��v���3)�J fn(�j��G�:M��:XE]�l�[9lO��i����3��%KRDL8[!�_�tu�DD��g���ѻ����},
V6���N�w�5$iXs�;E�C��`�OA]��RT����rz���;�[�������O��kD��S��t�[�����B�nV1��3�\��2۫*(�/�` �A �~�G�Uk�?��q���xq�3&}~���g|�y>VE�h��Z�!P<,Ъ����a����������2_k|��ؑ��`�����N��
��:��ZL��Da0������\6��T�҆\����7t���k۸��k����k]��=׶�6�Zm&�j4=����#��_"�W���+�|��7������7�vK���?�>#,���3�8C"Q],���em��P҇��::F00΋���H��]�ײ��isx;�G����csf�M��5u;��k�t~>?��x����������F義���W4��1o�~1o��0o�yͻg�6����dQNZ���|��;t����66�9��=l.�9��=��lۼ�˜��>���ǋ":=�����x���z���������]n��M�컍���� 0U���
@O�O�U�r�U�HZs�+�|�W<m>{����q���q���q�h�=�7ln&�X��c���oȎ�d���5Fw1���;�4z��{����.ܺ ���L3���1`��p�����}E�2��o���$~{X��i��L�ƴ_LŴ=L[h�@�ʹa�h3�vM��4�>���Fr�^�
��֨C�P��:�,��C�D%������v�j �I�i�w7ή��@F���ÎU�d�������v��YS�o:�Vk�C�4����.5775[^j�./uV�Z��!Bn&�a�2��jV��S[��v�jg5;Śӹ������oj~'a�)��#}Eܗ�o��Mq_�o��&�}S�Wƹck)��X%{)��,���d)!5�U@f� ī�L��8.�nB/CN6˙���z��~x;�z�1Ԇ�f��c{�/��NT�T_ �����3�*�eנ���Q;���к�NTA��?Gm��R�KQQQY�bY����J�d��T��R�"�`��u�T*��g0U+��(o����M+�d�Ǧkl�ŦMl�æ�6�`ӽM��.7��U���Xl���vĪ��3���6êV9���hŕ)6J��n7��}E��G~E5�o�iV���*�ae�G��~���J�{^�p��8���A�78�wX���>�Į���]7���#K���QiЪj�tRSj��&�b�<dY�(*J2U�"�r2���f�)�e�,o��l@�,��dJF\/���뛚dF}dH��U̐-�l�2$t��.����R�l7��X���8J�WLl<�����Z�������t(�`Ǌ��isf�f�dM�f5�c���Y}�7���A������&�0x����^������σ���#���veW�-�$��QJ��H��@K3R�j�%�"�/aX�K%����F^j$�F l���|��xէ���O͙�5V�*��Ó�IG�t����qFO��"�����
g���4O�0�M���y����[��H����A@� ^�e�#[�Ĕ��N&�f9��	ƴJmCD@��"��@AES�ȓ�7O��W}�J :C��|n��������B�}��	�<g�It~���w�����ڨ� c�"33""���PAFd����=K#ÌH0#%I9�:�q�o{
���*���,�_�W3�S��2p�l�`� 1g�/��-=L��1��FD��tzg	�u���$��=�}<?[�FUШ���	�."�A�����Hk$u\a=�"[�n�}ޕJ�Y�88�Ixo�r4ls��4�*v�ǨK��lZ��f���,�m��f�:c�-���ILԨ�!�<&����7����ϭcq�,#�y�mP"XB�[��
�o<���_�����ˀ�gJȰ2���ر*������M=�B�d��qX��%9����豉]�"���|���]#;��z�G��_d%���3%͈�y����HF˷d2m"�BS�w<�p� �t~ � b�f��@��M�U�	nIh�������k�����m�q���0���i7�%1�âw;��l�O�̚MM������� �ހN��Q�}��5�:B�R>�w=ߪ=��q\H�L.�\xcF�M\�'�#��9�=�P��TO��`U�8~Va3�]�P(�/�` �R ڥ<"Vp�ir�yڂO��(���M<7�b�%t9�Y��@n(h �cE���_��s���9����)Qs��������a����c�n;�_�?�K����~@N��۩�81wx���6�%��"��췔;K�z���� ��`�,;j��e�X6�e�,;�l�e��,{�V�n��qk��q�['om�u���[�n-sk������S+����lH-������Ҁ^b<:�C΍N���@�D@�T���K���G�"�SqL��F���YY����j"jf?[N��d��ʙ�����H6�*1G��ԈR��E�(�	�l7���Ɗ�|��YB>A�B&�+f��T��������~h0�qU��K��R3n��8O�b��Jh�Ym�����p����xx��?=<�p�Ë>�p��?4�t�O�`=;�g�pk��g�xv�g?=;�l㳋�>�l�g�\vd��z�]G�Z�k�f��]�vM��A�`��Ȯ�nU�K�x�ک�����4Ϟ��A��b!��6�'�%��B�	��ƀ=���R�K���&�d������t�;:�N�N��"Ӳc��x�����
�������oO�ط�\ط�nl�O.l�Nn��Uv�7�8)�F(�����\��7����]���W]��ɵm�q_�y\���{$�ů������_�v���W9�t+;!:!���P��B1�&�&���pA3AT%p�*A+1 Б���P
�$pB�`>O�I�~��~Sz�=S|��|Bz(z�/�����'O����x.;(;���bv,�tQtNtJt,�tCt@t�t� ����t,�U��9$9#9��1g�]�аۡ@�pT�!8�)9Crx���9ʩ�a2�j#�܊�t��=� ��n7�N�5`�٨j9j����"`w���� ��#�M	7����B���@b�d�C585V4Ih�xp����(�h1hP`��@a�0,fT�d'Ę��ؓ/L/ŗ+0"l��:u���H����(,<Xb��x%�d^K\�f\LZ!�fZPV>X�`%���C%�
M%
��2�
�
.N���.$��OLz*����ـ^�tE@7Sp|B"F�������!�����t��Llf����f���(�V:�ɭ ވ�Y��Kѣ�������+x�p{�|��F`���@j"��@�rK2u�ŀ�eWQJ�E����KkV���Y6)˩Mz:.��A#)))I ��h4g̘1�k���h(�f[ݚe��^�����\�0`�X�M�h�+�F#�ƍ���^,�"]���qS��.Z���ʸ���ŭ.��bQ�
*��L��k�1�W�8�Vwh""��ܤS��O1�;�[]-F��]1
(��.��=44D$�;�ŉ+�Fć+��Á\��"����7�p��{��h�W����q�B�p
nl�(ܗ�Cpa���U�����ڃ�pmj���\��r�;�����g#��K�q�K�:��8յ8
�f�>nl�F���w\����ؿ�3\�=��\ؾ�\⽋\{o���sa�Vr��[]�#��U��U׮>��Vra�<<�p����{�+�����}���e���"�;�U�-�������.���=ua�pC��qK�F�s�����n�}.,ۗ̕�ȕ7�l�/�<�t���ʑ;_ojj-o:���=�ב˗GO�P5��\�R>�K;ݎ�2g�\_��\y����u�����}���GP��;�Й7On��i����ʕ>��x����m����o{�{= '(�I��.-�M(mF�$�B�L�qu"�̨ӮQ��l"�쓹Z�m6m�ȳQ��i�ḲUj&`�&%�穴�T*p|a��|>��d�B�M'���>�M��\mؕ	j�lD�N&�}���̨u��d�6�v]*�Pf�h}|>���̦��\�? u<r��˨��m��0�v�y�B*���R�)
�\bF���vyT"�kSSi�����U�MP&u��B�V$�h���hr��6��TB��&�U��H��T���,T�T>��
=.9E-�6�LV}.�G�d�ͤ]�ʤ��X�vieB�У]:�GV]�G�uuZ(���O%�UW���y,�Q�#���~6,�a�w��� �C-�[Fh���5�Akĭhk��P�g`+6�֚�����e%]�$,��䨡D��$����H�$-p�����b5G&L�H��k��֬.����:'��4$���G��n�а �qd����E{�!~^�%�1�v6� �^~ީ�u�~ɗ���W�	qr�CbV�F�.	O���=7!;A��h��}�
�Ɂd�I���=2��-B����a���lm���+�(�����	�@mMXo;�m��!Q������e��%��=O�:�|���"k�	���l�;x5�4�͋�]�}�h�Ό���6�kﲈ6;�{/���/�}���r���t&౭��$|¯�w�Ho!�A���Z4���?>vw��3x��ݲ\������=�͏�+���<�x N0��o⫢��$���6�����x����
��D��R�b��Q�Ҵ}tv7�l���{�0ʆ�J9��zq"����%�WK��5��#�ɀ(�/�`�
�7 j�`90�l�x�������N������6��$Չ��5�F�-IR/I�e6���)Vkh�π����3�!g??�В��܈>���hF/�Б�;���,�0���^�2����,c��V��T�����';��L^�����#��D�������<ޱ�s���m㯽��4���c����,�Z��S�5�Ol��x�"1�?��sx��0������ƺ�L�	��?���?6r�͵�^{�c��;?�봓#7���Tv%�*3�d��ŵ�����ز�S*7.�4�dj/N�Rl�d�#w^cm��ˑ��x��w}܉T��9s��~�v���l��3o~��x��fF�.�yq�΋O"/��S��"����̑���x��>>�\l#��6vsc�ɓ?7����N��_v�96���Ȧzc"�*�C�|�6�~�S��Ǆ��G�	[c��;&�uLX縰2�qac|����¾�ƅu�׆u�׆mq׆eq��b���kV�1>lq6�/>��.F��-F,�Y�����&V1bK\UI�bT��QU�'F��8UA\�T�0����E��qb9��n�����'6�N,�7hXU�ΰ�^êja�U5��j�^U��^�
c]�õ��꿺�z�Wc}�ǌhiǤ2���l>�L�����|V8K;�ɖ�e+:��ҕ�`ue%8�~�w� X�]7ގ����f>���j^;�h>��Οh�����'W�y�g��v�z6��m��v�%L�#��L_��������1*g���:��W�`���O���f>���{�k�+T�L���%T����fյp�PEs��8T�^�>W ����󚶞��<�y5����x�+�w�+s;�uy�����{U>�&7བY�{%s�y������z� ��l�k�p����nU��,�c�Y����fQ5�澎y���͙�f��
��~��s�z9��_�lf�r��n����ZV��,'�+����+�AX+�ذ�l��,��dv�cV�b6���1b��,X'�Y�M��e�2�ˣ�d.����<�I֒�QE2�I��W&U#[�T�VeR%2�Ku�S.U!K�T�ʥ
�'��N���0y�=^�`y����8ɦ�c$G6�G¬�=��!o���QA�C�țE�l=��ư������|:��~
 ��鮩�^5[/�*q�Z:�laT��҈��҇���o���I�zS=����*�Roj�I����[;X0p�>p�:�o�r��nmt�om����h�ߺ�ߪh�ߚ���P�Ѡ��񆫡?�B��B�WB{:����t\Mw\7xnN�ܜ
hNqs���T~[��\1xS�r�`��j�����Kx�}&a���g��3M�
�ti�R���:�!LW	�4]#�w*p�>�;Ձ=�SXR�������wp]��uM`G��hO�3�=5ϋ���h���v���jgC��k�	}W:��s�]x�@�U΀�����Y�����0#� �$�H*rRH��!�:�RE���`dƤXg�e&AW������:!�0&�>�~6�s�⩗^�R��3�������n,�h���^�*�v�����1>fI\"{�����:;�]��M�$J:��B�U9��*{#�=A��F�ݎ�en!��i8�4e�2&ؽ���v�z�A���'�,t�!����J�}p[˸���ُ��4_,�{����.6X 7� y��T��?��9?>&[i�˵�E/JZ�Lw21G�wn�ԋ�/���rn�_P?RSCC [remap]

importer="font_data_dynamic"
type="FontFile"
uid="uid://hc171euyv6hw"
path="res://.godot/imported/junegull.ttf-4aaf4c1832ae6d952e8acc0d8b3b8931.fontdata"
             RSRC                    Theme            ��������                                                  resource_local_to_scene    resource_name    default_base_scale    default_font    default_font_size !   CheckButton/font_sizes/font_size !   HeaderLarge/font_sizes/font_size    Label/font_sizes/font_size    LineEdit/font_sizes/font_size    PanelContainer/styles/panel    script    	   FontFile    res://junegull.ttf (�L��      local://Theme_3kjqc �         Theme                                 *                       	          
      RSRC              class_name SplitTab

extends HBoxContainer

var distText = "Dist"
var goalText = "Goal"
var totalText = "Time"
var splitTimeText = "Split"
var aheadBehindText = "+/-"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Distance.text = distText
	$GoalTime.text = goalText
	$TotalTime.text = totalText
	$SplitTime.text = splitTimeText
	#if float(aheadBehindText) > 0:
	#	$AheadBehind.text = "+" + aheadBehindText
	#else:
	$AheadBehind.text = aheadBehindText
     RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://SplitTab.gd ��������      local://PackedScene_enjwa 	         PackedScene          	         names "      	   SplitTab    offset_right    offset_bottom    size_flags_horizontal    script    HBoxContainer    Control    custom_minimum_size    layout_mode 	   Distance    size_flags_stretch_ratio    Label 	   GoalTime 
   TotalTime 
   SplitTime    AheadBehind    	   variants             B                
      A             ��L?      node_count             nodes     S   ��������       ����                                               ����                              	   ����               
                        ����                                 ����                                 ����                                 ����                         conn_count              conns               node_paths              editable_instances              version             RSRC        [remap]

path="res://.godot/exported/133200997/export-e26ba1523f1e66f414fed51ed52c7402-calculator.scn"
         [remap]

path="res://.godot/exported/133200997/export-96f04d1941a93a42547eb49c5900d128-MainTheme.res"
          [remap]

path="res://.godot/exported/133200997/export-45c2fd9952f64ecaf7682c7d1a6f75e1-SplitTab.scn"
           list=Array[Dictionary]([{
"base": &"HBoxContainer",
"class": &"SplitTab",
"icon": "",
"language": &"GDScript",
"path": "res://SplitTab.gd"
}])
 <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             n�G�<�i   res://calculator.tscn,��zbe(m   res://icon.svg(�L��   res://junegull.ttfP��2��@   res://MainTheme.tresm�d.T%   res://SplitTab.tscn    ECFG      application/config/name         SmartSplits    application/run/main_scene          res://calculator.tscn      application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg     display/window/stretch/mode         canvas_items   gui/theme/custom         res://MainTheme.tres#   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility         