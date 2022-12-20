package com.dzenm.flutter_ui.study;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Stack;

public class JavaStudy {

    static class ListNode {
        ListNode next;
        int value;
    }

    void printNode(ListNode head) {
        ListNode node = head;
        while (node != null) {
            System.out.println(node.value);
        }
    }

    public static void main() {
        int[] arr1 = new int[]{19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18};
        int[] arr2 = new int[]{19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18};
        int[] arr3 = new int[]{19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18};

        System.out.println("Java快速排序前：" + Arrays.toString(arr1));
        quickSort(arr1, 0, arr1.length - 1);
        System.out.println("Java快速排序后：" + Arrays.toString(arr1));

        System.out.println("Java归并排序前：" + Arrays.toString(arr2));
        mergeSort(arr2, new int[arr2.length], 0, arr2.length - 1);
        System.out.println("Java归并排序后：" + Arrays.toString(arr2));

        System.out.println("Java小堆排序前：" + Arrays.toString(arr3));
        heapSort(arr3);
        System.out.println("Java小堆排序后：" + Arrays.toString(arr3));
        dp();
    }


    static void quickSort(int[] arr, int lo, int hi) {
        if (lo < hi) {
            int pivot = partition(arr, lo, hi);
            quickSort(arr, lo, pivot);
            quickSort(arr, pivot + 1, hi);
        }
    }

    static int partition(int[] arr, int lo, int hi) {
        int temp = arr[lo];
        while (lo < hi) {
            while (lo < hi && arr[hi] >= temp) hi--;
            arr[lo] = arr[hi];
            while (lo < hi && arr[lo] <= temp) lo++;
            arr[hi] = arr[lo];
        }
        arr[lo] = temp;
        return lo;
    }

    static void mergeSort(int[] arr, int[] temp, int lo, int hi) {
        if (lo < hi) {
            int mid = lo + (hi - lo) / 2;
            mergeSort(arr, temp, lo, mid);
            mergeSort(arr, temp, mid + 1, hi);
            merge(arr, temp, lo, hi, mid + 1);
        }
    }

    static void merge(int[] arr, int[] temp, int lo, int hi, int mid) {
        int len = hi - lo + 1;
        int p = lo, i = lo, j = mid;
        while (i < mid && j <= hi) temp[p++] = arr[i] < arr[j] ? arr[i++] : arr[j++];
        while (i < mid) temp[p++] = arr[i++];
        while (j <= hi) temp[p++] = arr[j++];
        for (int k = 0; k < len; k++, hi--) {
            arr[hi] = temp[hi];
        }
    }

    static void heapSort(int[] arr) {
        int len = arr.length;
        for (int i = len - 1; i >= 0; i--) {
            maxHeap(arr, i, len);
        }

        for (int i = len - 1; i > 0; i--) {
            int temp = arr[0];
            arr[0] = arr[i];
            arr[i] = temp;
            maxHeap(arr, 0, i);
        }
    }

    static void maxHeap(int[] arr, int i, int len) {
        int temp = arr[i];
        for (int j = 2 * i + 1; j < len; j = 2 * j + 1) {
            if (j + 1 < len && arr[j] < arr[j + 1]) j++;
            if (arr[j] > temp) {
                arr[i] = arr[j];
                i = j;
            } else break;
        }
        arr[i] = temp;
    }

    static void dp() {
        int[] dp = new int[20];
        dp[0] = 1;
        dp[1] = 2;
        dp[2] = 3;
        for (int i = 3; i < dp.length; i++) {
            dp[i] = dp[i - 1] + dp[i - 2] + dp[i - 3];
        }

        for (int i = dp.length - 1; i >= 0; i--) {
            if ((i + 1) % 5 == 0) {
                System.out.println();
            }
            System.out.print(dp[i] + ",");
        }
    }

    void testNode(Node root) {
        List<Integer> list = new ArrayList<>();
        Stack<Node> stack = new Stack<>();
        stack.add(root);
        while (!stack.empty()) {
            if (stack.peek() == null) {
                stack.pop();
            } else if (stack.peek() != null) {
                stack.add(stack.peek().left);
            } else {

            }
        }
    }

    static class Node {
        Node left;
        Node right;
        int val;
    }
}
