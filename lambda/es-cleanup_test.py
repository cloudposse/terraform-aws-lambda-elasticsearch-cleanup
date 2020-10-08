"""
THIS FILE IS NOT EXACTLY THE ORIGINAL FILE DISTRIBUTED BY Cloudreach Europe Limited
IT HAS BEEN MODIFIED BY Cloud Posse, LLC

Derived from https://github.com/cloudreach/aws-lambda-es-cleanup/blob/v0.14/es_cleanup_test.py
"""

import datetime
import unittest
import importlib

es_cleanup = importlib.import_module("es-cleanup")

IDX_REGEX = '.*'
IDX_FORMAT1 = '%Y.%m.%d'
SKIP_IDX_REGEX = '^\\.kibana*'

decider = es_cleanup.DeleteDecider(delete_after=4,
                                   idx_format=IDX_FORMAT1,
                                   idx_regex=IDX_REGEX,
                                   skip_idx_regex=SKIP_IDX_REGEX,
                                   today=datetime.date(2019, 12, 19))


class TestShouldDelete(unittest.TestCase):
    def test_should_be_deleted(self):
        tuple = decider.should_delete({"index": "k8s-2019.12.14"})
        self.assertTrue(tuple[0])

    def test_should_not_be_deleted(self):
        tuple = decider.should_delete({"index": "k8s-2019.12.15"})
        self.assertFalse(tuple[0])

    def test_should_raise_value_error(self):
        with self.assertRaises(ValueError):
            decider.should_delete({"index": "k8s-2019-12-15"})

    def test_should_raise_value_error_2(self):
        with self.assertRaises(ValueError):
            decider.should_delete({"index": ".Kibana"})

    def test_should_raise_value_error_3(self):
        with self.assertRaises(ValueError):
            decider.should_delete({"index": ".Kibana_1"})

    def test_should_skip_index(self):
        tuple = decider.should_delete({"index": ".kibana"})
        self.assertFalse(tuple[0])
        self.assertTrue("matches skip condition" in tuple[1])

    def test_should_skip_index_2(self):
        tuple = decider.should_delete({"index": ".kibana_1"})
        self.assertFalse(tuple[0])
        self.assertTrue("matches skip condition" in tuple[1])





decider2 = es_cleanup.DeleteDecider(delete_after=4,
                                    idx_format='%Y-%m-%d',
                                    idx_regex='app[1-2].*|k8s.*|dev-west',
                                    skip_idx_regex='kibana.*',
                                    today=datetime.date(2019, 12, 19))


class TestShouldDelete2(unittest.TestCase):
    def test_should_be_deleted(self):
        tuple = decider2.should_delete({"index": "k8s-2019-12-14"})
        self.assertTrue(tuple[0])

    def test_should_not_be_deleted(self):
        tuple = decider2.should_delete({"index": "k8s-2019-12-15"})
        self.assertFalse(tuple[0])

    def test_should_be_deleted_dev(self):
        tuple = decider2.should_delete({"index": "dev-west-2019-12-14"})
        self.assertTrue(tuple[0])

    def test_should_not_be_deleted_dev(self):
        tuple = decider2.should_delete({"index": "dev-west-2019-12-15"})
        self.assertFalse(tuple[0])

    def test_should_not_be_deleted_dev(self):
        tuple = decider2.should_delete({"index": "dev-2019-12-15"})
        self.assertFalse(tuple[0])

    def test_should_be_deleted_app1(self):
        tuple = decider2.should_delete({"index": "app1-2019-12-14"})
        self.assertTrue(tuple[0])

    def test_should_not_be_deleted_app1(self):
        tuple = decider2.should_delete({"index": "app1-2019-12-15"})
        self.assertFalse(tuple[0])

    def test_should_be_deleted_app2(self):
        tuple = decider2.should_delete({"index": "app2-2019-12-14"})
        self.assertTrue(tuple[0])

    def test_should_not_be_deleted_app2(self):
        tuple = decider2.should_delete({"index": "app2-2019-12-15"})
        self.assertFalse(tuple[0])

    def test_should_not_be_deleted_app3(self):
        tuple = decider2.should_delete({"index": "app3-2019-12-14"})
        self.assertFalse(tuple[0])

    def test_should_raise_value_error(self):
        with self.assertRaises(ValueError):
            decider2.should_delete({"index": "k8s-2019.12.5"})

    def test_should_skip_index(self):
        tuple = decider2.should_delete({"index": ".kibana"})
        self.assertFalse(tuple[0])
        self.assertTrue("matches skip condition" in tuple[1])

    def test_should_skip_index_2(self):
        tuple = decider2.should_delete({"index": ".kibana_1"})
        self.assertFalse(tuple[0])
        self.assertTrue("matches skip condition" in tuple[1])


if __name__ == '__main__':
    unittest.main()
