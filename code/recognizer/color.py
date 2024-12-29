import cv2
import numpy as np


def crop(img, x):
    # 画像を縦横X等分した中央を返す
    h, w = img.shape[:2]
    return img[h//2-x:h//2+x, w//2-x:w//2+x]


class ColorRecognizer:
    def recognize_color(self, frame: cv2.VideoCapture) -> str:

        frame = crop(frame, 3)

        hsv_image = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

        # 例として赤、緑、青
        color_ranges = {
            'red': [(0, 50, 50), (10, 255, 255)],
            'green': [(50, 50, 50), (70, 255, 255)],
            'blue': [(110, 50, 50), (130, 255, 255)]
        }

        color_count = {color: 0 for color in color_ranges}

        # 各色のマスクを作成し、その色のピクセル数を数える
        for color, (lower, upper) in color_ranges.items():
            mask = cv2.inRange(hsv_image, np.array(lower), np.array(upper))
            color_count[color] = cv2.countNonZero(mask)

        recognized_color = max(color_count, key=color_count.get)
        return recognized_color
    
    def recognize_specific_color(self, frame: cv2.VideoCapture, color: str) -> bool:
        recognized_color = self.recognize_color(frame)
        return recognized_color == color


if __name__ == "__main__":
    cap = cv2.VideoCapture(0)
    color_recognizer = ColorRecognizer()
    while True:
        ret, frame = cap.read()
        color = color_recognizer.recognize_color(frame)
        frame = crop(frame, 3)
        cv2.putText(frame, color, (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 2, cv2.LINE_AA)
        cv2.imshow("frame", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
