SELECT tmo_test_result.*,
       tmo_test_result.test_result_id,
       tmo_test_result.customer_functional_group_id,
       tmo_test_result.test_station_id,
       tmo_test_result.gui_version_id,
       tmo_test_result.rf_tester_sn,
       tmo_test_result.port,
       tmo_test_result.rf_shield_box_sn,
       tmo_test_result.rf_cable_sn,
       tmo_test_result.attenuation_id,
       tmo_test_result.test_result_type_id,
       tmo_test_result.product_id,
       tmo_test_result.test_suite_version_id,
       tmo_test_result.imei,
       tmo_test_result.test_status_id,
       tmo_test_result.user_id,
       tmo_test_result.start_date,
       tmo_test_result.stop_date,
       tmo_test_result.error_id
FROM (
        (
           (
              (
                 (
                    (
                       (
                          (
                             armsprd.test_station test_station
                             INNER JOIN
                             armsprd.customer_functional_group_def
                             customer_functional_group_def
                                ON (test_station.customer_functional_group_id =
                                    customer_functional_group_def.customer_functional_group_id))
                          INNER JOIN armsprd.tmo_test_result tmo_test_result
                             ON     (tmo_test_result.test_station_id =
                                     test_station.test_station_id)
                                AND (tmo_test_result.customer_functional_group_id =
                                     customer_functional_group_def.customer_functional_group_id))
                       INNER JOIN armsprd.tmo_attenuation tmo_attenuation
                          ON     (tmo_test_result.attenuation_id =
                                  tmo_attenuation.attenuation_id)
                             AND (tmo_attenuation.test_station_id =
                                  test_station.test_station_id)
                             AND (tmo_attenuation.customer_functional_group_id =
                                  customer_functional_group_def.customer_functional_group_id))
                    INNER JOIN armsprd.product product
                       ON     (tmo_test_result.product_id =
                               product.product_id)
                          AND (tmo_attenuation.product_id =
                               product.product_id))
                 INNER JOIN armsprd.error_def error_def
                    ON     (tmo_test_result.error_id = error_def.error_id)
                       AND (tmo_attenuation.error_id = error_def.error_id))
              INNER JOIN armsprd.gui_version_def gui_version_def
                 ON     (tmo_test_result.gui_version_id =
                         gui_version_def.gui_version_id)
                    AND (tmo_attenuation.gui_version_id =
                         gui_version_def.gui_version_id))
           INNER JOIN armsprd.test_status_def test_status_def
              ON     (tmo_attenuation.test_status_id =
                      test_status_def.test_status_id)
                 AND (tmo_test_result.test_status_id =
                      test_status_def.test_status_id))
        INNER JOIN armsprd.user user
           ON     (tmo_attenuation.user_id = user.user_id)
              AND (tmo_test_result.user_id = user.user_id))
     INNER JOIN armsprd.test_result_type_def test_result_type_def
        ON (tmo_test_result.test_result_type_id =
            test_result_type_def.test_result_type_id)