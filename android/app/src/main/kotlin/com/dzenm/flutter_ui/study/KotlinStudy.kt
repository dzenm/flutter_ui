package com.dzenm.flutter_ui.study

class KotlinStudy {

    companion object {
        fun main() {
            val arr1 = intArrayOf(19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18)
            val arr2 = intArrayOf(19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18)
            val arr3 = intArrayOf(19, 34, 25, 12, 78, 61, 49, 25, 98, 86, 61, 18)

            println("Kotlin快速排序前：" + arr1.contentToString())
            quickSort(arr1, 0, arr1.size - 1)
            println("Kotlin快速排序后：" + arr1.contentToString())

            println("Kotlin归并排序前：" + arr2.contentToString())
            mergeSort(arr2, IntArray(arr2.size), 0, arr2.size - 1)
            println("Kotlin归并排序后：" + arr2.contentToString())

            println("Kotlin小堆排序前：" + arr3.contentToString())
            heapSort(arr3)
            println("Kotlin小堆排序后：" + arr3.contentToString())
        }

        private fun mergeSort(arr: IntArray, temp: IntArray, lo: Int, hi: Int) {
            if (lo < hi) {
                val mid = lo + (hi - lo) / 2;
                mergeSort(arr, temp, lo, mid)
                mergeSort(arr, temp, mid + 1, hi)
                merge(arr, temp, lo, hi, mid + 1)
            }
        }

        private fun merge(arr: IntArray, temp: IntArray, lo: Int, hi: Int, mid: Int) {
            var p = lo
            var i = lo
            var j = mid
            while (i < mid && j <= hi) temp[p++] = if (arr[i] < arr[j]) arr[i++] else arr[j++]
            while (i < mid) temp[p++] = arr[i++]
            while (j <= hi) temp[p++] = arr[j++]

            for (k in hi downTo lo) arr[k] = temp[k]
        }


        private fun quickSort(arr: IntArray, lo: Int, hi: Int) {
            if (lo < hi) {
                val pivot = partition(arr, lo, hi)
                quickSort(arr, lo, pivot)
                quickSort(arr, pivot + 1, hi)
            }
        }

        private fun partition(arr: IntArray, lo: Int, hi: Int): Int {
            var i = lo
            var j = hi
            val temp = arr[i]
            while (i < j) {
                while (i < j && arr[j] >= temp) j--
                arr[i] = arr[j]
                while (i < j && arr[i] <= temp) i++
                arr[j] = arr[i]
            }
            arr[i] = temp
            return i
        }

        private fun heapSort(arr: IntArray) {
            val len = arr.size
            for (i in len - 1 downTo 0) {
                maxHeap(arr, i, len)
            }
            for (i in len - 1 downTo 1) {
                val t = arr[i]
                arr[i] = arr[0]
                arr[0] = t
                maxHeap(arr, 0, i)
            }
        }

        private fun maxHeap(arr: IntArray, pos: Int, len: Int) {
            var i = pos
            var j = 2 * i + 1
            val temp = arr[i]
            while (j < len) {
                if (j + 1 < len && arr[j] < arr[j + 1]) j++
                if (arr[j] > temp) {
                    arr[i] = arr[j]
                    i = j
                } else break
                j = 2 * j + 1
            }
            arr[i] = temp
        }
    }
}