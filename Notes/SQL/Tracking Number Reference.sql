[select /*crtnid,
 ship_id,
 ordnum,
 wrkref,
 prtnum,*/
 carcod,
 srvlvl,
        traknm,
        shpdte,
        lodnum,
        podnum,
        rownum
   from manfst
  where traknm in ('92748999985532553002483483', '92748999985532553003486162', '92748999985532553003486353', '92748999985532553003489170', '92748999985532553003489651', '92748999985532553003491203', '92748999985532553003491869', '92748999985532553003494037', '92748999985532553003494082', '92748999985532553003494839', '92748999985532553003495164', '92748999985532553003495874', '92748999985532553003500868', '92748999985532553003505573', '92748999985532553003515039', '92748999985532553003515060', '92748999985532553003515275', '92748999985532553003515763', '92748999985532553003526301', '92748999985532553003527339', '92748999985532553003527377', '92748999985532553003528916', '92748999985532553003529180', '92748999985532553003529371', '92748999985532553003529753', '92748999985532553003531077', '92748999985532553003531909', '92748999985532553003532944', '92748999985532553003533231', '92748999985532553003533293', '92748999985532553003534689', '92748999985532553003536041', '92748999985532553003536904', '92748999985532553003540376', '92748999985532553003540949', '92748999985532553003543186', '92748999985532553003544855', '92748999985532553003545548', '92748999985532553003546439', '92748999985532553003548631', '92748999985532553003549065', '92748999985532553003551136', '92748999985532553003552560', '92748999985532553003552782', '92748999985532553003553185', '92748999985532553003554144', '92748999985532553003555523', '92748999985532553003555707', '92748999985532553003557275', '92748999985532553003557640', '92748999985532553003560176', '92748999985532553003562200', '92748999985532553003476477', '92748999985532553003476958', '92748999985532553003477641', '92748999985532553003479201', '92748999985532553003485240', '92748999985532553003485325', '92748999985532553003487602', '92748999985532553003487725', '92748999985532553003488470', '92748999985532553003489460', '92748999985532553003489767', '92748999985532553003490138', '92748999985532553003490312', '92748999985532553003490374', '92748999985532553003491067', '92748999985532553003491302', '92748999985532553003491722', '92748999985532553003491753', '92748999985532553003492293', '92748999985532553003492798', '92748999985532553003493412', '92748999985532553003493559', '92748999985532553003493719', '92748999985532553003494686', '92748999985532553003494853', '92748999985532553003495669', '92748999985532553003496642', '92748999985532553003497366', '92748999985532553003498011', '92748999985532553003498271', '92748999985532553003498394', '92748999985532553003498639', '92748999985532553003499452', '92748999985532553003499568', '92748999985532553003500134', '92748999985532553003500400', '92748999985532553003500813', '92748999985532553003501216', '92748999985532553003501964', '92748999985532553003502480', '92748999985532553003502732', '92748999985532553003503678', '92748999985532553003504491', '92748999985532553003504781', '92748999985532553003506532', '92748999985532553003510010', '92748999985532553003510300', '92748999985532553003512014', '92748999985532553003512595', '92748999985532553003512601', '92748999985532553003512885', '92748999985532553003513370', '92748999985532553003513998', '92748999985532553003514780', '92748999985532553003514865', '92748999985532553003515046', '92748999985532553003515084', '92748999985532553003515978', '92748999985532553003516081', '92748999985532553003516586', '92748999985532553003517347', '92748999985532553003517989', '92748999985532553003518818', '92748999985532553003519433', '92748999985532553003520118', '92748999985532553003521894', '92748999985532553003522013', '92748999985532553003522198', '92748999985532553003522259', '92748999985532553003522556', '92748999985532553003522600', '92748999985532553003523331', '92748999985532553003523348', '92748999985532553003523843', '92748999985532553003524789', '92748999985532553003525076', '92748999985532553003525298', '92748999985532553003525397', '92748999985532553003525427', '92748999985532553003525618', '92748999985532553003525717', '92748999985532553003526714', '92748999985532553003526813', '92748999985532553003527001', '92748999985532553003527063', '92748999985532553003527292', '92748999985532553003527698', '92748999985532553003528794', '92748999985532553003529456', '92748999985532553003529470', '92748999985532553003529531', '92748999985532553003529647', '92748999985532553003529937', '92748999985532553003531022', '92748999985532553003531152', '92748999985532553003531565', '92748999985532553003531701', '92748999985532553003532685', '92748999985532553003532920', '92748999985532553003533316', '92748999985532553003534801', '92748999985532553003534894', '92748999985532553003535259', '92748999985532553003536324', '92748999985532553003537130', '92748999985532553003537628', '92748999985532553003537932', '92748999985532553003538083', '92748999985532553003538199', '92748999985532553003538267', '92748999985532553003538335', '92748999985532553003538458', '92748999985532553003538472', '92748999985532553003538618', '92748999985532553003539905', '92748999985532553003540543', '92748999985532553003540581', '92748999985532553003540758', '92748999985532553003540789', '92748999985532553003541809', '92748999985532553003542028', '92748999985532553003542035', '92748999985532553003542097', '92748999985532553003542592', '92748999985532553003543803', '92748999985532553003543926', '92748999985532553003543933', '92748999985532553003544268', '92748999985532553003544572', '92748999985532553003545913', '92748999985532553003546415', '92748999985532553003546491', '92748999985532553003547085', '92748999985532553003548532', '92748999985532553003548945', '92748999985532553003550399', '92748999985532553003550405', '92748999985532553003551020', '92748999985532553003551495', '92748999985532553003553383', '92748999985532553003553826', '92748999985532553003553932', '92748999985532553003554007', '92748999985532553003554038', '92748999985532553003554984', '92748999985532553003555028', '92748999985532553003555585', '92748999985532553003556025', '92748999985532553003556315', '92748999985532553003556544', '92748999985532553003556902', '92748999985532553003557022', '92748999985532553003557053', '92748999985532553003557213', '92748999985532553003557473', '92748999985532553003557688', '92748999985532553003557961', '92748999985532553003558036', '92748999985532553003558081', '92748999985532553003558128', '92748999985532553003559361', '92748999985532553003559569', '92748999985532553003559705', '92748999985532553003559996', '92748999985532553003560053', '92748999985532553003560343', '92748999985532553003560442', '92748999985532553003560879', '92748999985532553003560985', '92748999985532553003561166', '92748999985532553003561319', '92748999985532553003561999', '92748999985532553003562347', '92748999985532553000491596', '92748999985532553003486568', '92748999985532553003493740', '92748999985532553003494891', '92748999985532553003495973', '92748999985532553003496567', '92748999985532553003497533', '92748999985532553003497632', '92748999985532553003498868', '92748999985532553003501902', '92748999985532553003502039', '92748999985532553003503302', '92748999985532553003504750', '92748999985532553003504897', '92748999985532553003505382', '92748999985532553003505603', '92748999985532553003507379', '92748999985532553003507980', '92748999985532553003508277', '92748999985532553003509533', '92748999985532553003511871', '92748999985532553003512731', '92748999985532553003513424', '92748999985532553003513646', '92748999985532553003514599', '92748999985532553003514841', '92748999985532553003514971', '92748999985532553003515596', '92748999985532553003516142', '92748999985532553003517729', '92748999985532553003517859', '92748999985532553003522549', '92748999985532553003524826', '92748999985532553003525915', '92748999985532553003526677', '92748999985532553003527490', '92748999985532553003528244', '92748999985532553003528459', '92748999985532553003528497', '92748999985532553003528893', '92748999985532553003528978', '92748999985532553003529975', '92748999985532553003530452', '92748999985532553003531473', '92748999985532553003531480', '92748999985532553003532166', '92748999985532553003533576', '92748999985532553003534283', '92748999985532553003534337', '92748999985532553003534474', '92748999985532553003534825', '92748999985532553003536966', '92748999985532553003537765', '92748999985532553003538427', '92748999985532553003539035', '92748999985532553003540345', '92748999985532553003540932', '92748999985532553003541373', '92748999985532553003542417', '92748999985532553003543155', '92748999985532553003543292', '92748999985532553003543896', '92748999985532553003546095', '92748999985532553003549751', '92748999985532553003549898', '92748999985532553003550863', '92748999985532553003553369', '92748999985532553003553581', '92748999985532553003555295', '92748999985532553003558494', '92748999985532553003560473', '92748999985532553003560640', '92748999985532553003561326', '92748999985532553003562163', '92748999985532553003563085', '92748999985532553003614886', '92748999985532553003638493', '92748999985532553000081612', '92748999985532553003675825', '92748999985532553003702828', '92748999985532553003603156', '92748999985532553003677348', '92748999985532553003685886', '92748999985532553002494687', '92748999985532553003709087', '92748999985532553000378842', '92748999985532553002103190', '92748999985532553003660180', '92748999985532553003676235', '92748999985532553000264220', '92748999985532553001995710', '92748999985532553002557139', '92748999985532553003720792', '92748999985532553003771718', '92748999985532553003787740', '92748999985532553001633568', '92748999985532553003838015', '92748999985532553003839371', '92748999985532553003850895', '92748999985532553003853025', '92748999985532553000320957', '92748999985532553003744118', '92748999985532553003769302', '92748999985532553003774917', '92748999985532553003799101', '92748999985532553002538800', '92748999985532553003769005', '92748999985532553003784794', '92748999985532553003795271', '92748999985532553003821796', '92748999985532553002116350', '92748999985532553003932386', '92748999985532553002423700', '92748999985532553003814910', '92748999985532553003840193', '92748999985532553003854282', '92748999985532553003880137', '92748999985532553003883688', '92748999985532553003883732', '92748999985532553003883787', '92748999985532553003884098', '92748999985532553003884142', '92748999985532553003889314', '92748999985532553003903034', '92748999985532553003959895', '92748999985532553003962611', '92748999985532553003962697', '92748999985532553003962734', '92748999985532553003962918', '92748999985532553003963274', '92748999985532553003963496', '92748999985532553003963632', '92748999985532553003965360', '92748999985532553003965407', '92748999985532553003965483', '92748999985532553003854275', '92748999985532553003854978', '92748999985532553003883831', '92748999985532553003884005', '92748999985532553003898200', '92748999985532553003903720', '92748999985532553003959734', '92748999985532553003962765', '92748999985532553003962802', '92748999985532553003962956', '92748999985532553003963052', '92748999985532553003963106', '92748999985532553003963175', '92748999985532553003963434', '92748999985532553003963571', '92748999985532553003963717', '92748999985532553003963779', '92748999985532553003963984', '92748999985532553003964882', '92748999985532553003964974', '92748999985532553003965001', '92748999985532553003965025', '92748999985532553003965223', '92748999985532553003965254', '92748999985532553003965322', '92748999985532553003965438', '92748999985532553003965452', '92748999985532553003965520', '92748999985532553003965551', '92748999985532553003965582', '92748999985532553003965605', '92748999985532553003965636', '92748999985532553003965650', '92748999985532553003965674', '92748999985532553003965681', '92748999985532553003965698', '92748999985532553003965728')]